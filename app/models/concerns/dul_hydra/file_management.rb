module DulHydra
  module FileManagement
    extend ActiveSupport::Concern

    EXTERNAL_FILE_PERMISSIONS = 0644

    included do
      attr_accessor :file_to_add

      define_model_callbacks :add_file
      before_add_file :virus_scan

      after_save :notify_virus_scan_results

      # Deleting the datastream external files on destroying the object can't 
      # be handled with a datastream around_destroy callback.
      # See https://groups.google.com/d/msg/hydra-tech/xJaZr2wVhbg/4iafvso98w8J
      around_destroy :cleanup_external_files_on_destroy
    end

    # Comparable to Hydra::ModelMethods method add_file(file, dsid, file_name)
    def add_file file, dsid, opts={}
      self.file_to_add = file

      opts[:file_name] ||= DulHydra::Utils.file_name_for(file)
      opts[:mime_type] ||= DulHydra::Utils.mime_type_for(file, opts[:file_name])

      run_callbacks(:add_file) do
        if opts.delete(:external) || datastreams.include?(dsid) && datastreams[dsid].external?
          add_external_file(file, dsid, opts)
        else
          # ActiveFedora method
          add_file_datastream(file, dsid: dsid, mimeType: opts[:mime_type])
        end
      end

      self.file_to_add = nil
    end

    # Normally this method should not be called directly
    # Call #add_file with dsid for external datastream id, or :external => true if no spec for dsid
    def add_external_file file, dsid, opts={}
      file_path = DulHydra::Utils.file_path(file) # raises ArgumentError

      # Retrieve or create the datastream
      ds = datastreams.include?(dsid) ? datastreams[dsid] : add_external_datastream(dsid)

      raise ArgumentError, "Cannot add external file to datastream with controlGroup \"#{ds.controlGroup}\": #{ds.inspect}" unless ds.external?

      raise DulHydra::Error, "Cannot add external file to datastream when dsLocation change is pending." if ds.dsLocation_changed?

      # set the mime type
      # the :mime_type option will be set when called from #add_file
      # the fallback is there in case #add_external_file is called directly
      ds.mimeType = opts[:mime_type] || DulHydra::Utils.mime_type_for(file, file_path)

      # copy the file to storage unless we're using the original
      if opts[:use_original]
        raise DulHydra::Error, "Cannot add file to repository that is owned by another user." unless File.owned?(file_path)
        store_path = file_path
      else
        # generate storage path
        file_name = opts[:file_name] || DulHydra::Utils.file_name_for(file)
        store_path = File.join(create_external_directory!, file_name)
        # copy the original file to the storage location
        FileUtils.cp file_path, store_path
      end

      # set appropriate permissions on the file
      set_external_file_permissions!(store_path)

      ds.dsLocation = DulHydra::Utils.path_to_uri(store_path)
    end

    def create_external_directory!
      created = FileUtils.mkdir_p(generate_external_directory_path)
      created.first
    end

    #
    # Generates a new directory storage location
    #
    # => {external_file_store}/1/e/69/1e691815-0631-4f9b-8e23-2dfb2eec9c70
    #
    def generate_external_directory_path
      File.join(external_file_store, generate_external_directory_subpath)
    end

    def external_datastreams
      datastreams.values.select { |ds| ds.external? }
    end

    def external_datastream_file_paths
      external_datastreams.map(&:file_paths).flatten
    end
    
    def add_external_datastream dsid, opts={}
      klass = self.class.datastream_class_for_name(dsid)
      datastream = create_datastream(klass, dsid, controlGroup: "E")
      add_datastream(datastream)
      self.class.build_datastream_accessor(dsid)
      datastream
    end

    protected

    def virus_scan_results
      @virus_scan_results ||= []
    end

    def virus_scan
      if DulHydra::Utils.file_or_path?(file_to_add) # can't virus scan blob
        virus_scan_results << DulHydra::Services::Antivirus.scan(file_to_add) 
      end
    end

    def notify_virus_scan_results
      while result = virus_scan_results.shift
        ActiveSupport::Notifications.instrument(DulHydra::Notifications::VIRUS_CHECK, result: result, pid: pid)
      end
    end

    def external_file_store
      DulHydra.external_file_store
    end

    def set_external_file_permissions! file_path
      File.chmod(EXTERNAL_FILE_PERMISSIONS, file_path)
    end

    def generate_external_directory_name
      SecureRandom.uuid      
    end

    def generate_external_directory_subpath 
      dirname = generate_external_directory_name
      m = DulHydra.external_file_subpath_regexp.match(dirname)
      subpath_segments = m.to_a[1..-1]
      subpath_segments << dirname
      File.join *subpath_segments
    end

    def cleanup_external_files_on_destroy
      paths = external_datastream_file_paths
      yield
      File.unlink *paths
    end

  end
end
