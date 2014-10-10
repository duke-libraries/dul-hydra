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

    # add_file(file, dsid, opts={})
    #
    # Comparable to Hydra::ModelMethods#add_file(file, dsid, file_name)
    #
    # Options:
    #
    #   :mime_type - Explicit mime type to set (otherwise discerned from file path or name)
    #
    #   :original_name - A String value will be understood as the original name of the file.
    #                    `false` or `nil` indicate that the file basename is not the original 
    #                    name. Default processing will take the file basename as the original 
    #                    name.
    #
    #   :external - Add to file to external datastream. Not required for datastream specs
    #               where :control_group=>"E".
    #
    #   :use_original - For external datastream file, do not copy file to new file path,
    #                   but use in place (set dsLocation to file URI for current path.
    def add_file file, dsid, opts={}
      opts[:mime_type] ||= DulHydra::Utils.mime_type_for(file)

      # @file_to_add is set for callbacks to access the data
      original_name = opts.fetch(:original_name, DulHydra::Utils.file_name_for(file))
      self.file_to_add = FileToAdd.new(file, dsid, original_name)

      run_callbacks(:add_file) do
        if opts.delete(:external) || datastreams.include?(dsid) && datastreams[dsid].external?
          add_external_file(file, dsid, opts)
        else
          file = File.new(file, "rb") if DulHydra::Utils.file_path?(file)
          # ActiveFedora method accepts file-like objects, not paths
          add_file_datastream(file, dsid: dsid, mimeType: opts[:mime_type]) 
        end
      end

      # clear the instance data
      self.file_to_add = nil
    end

    # Normally this method should not be called directly. Call `add_file` with dsid for 
    # external datastream id, or with `:external=>true` option if no spec for dsid.
    def add_external_file file, dsid, opts={}
      file_path = DulHydra::Utils.file_path(file) # raises ArgumentError

      # Retrieve or create the datastream
      ds = datastreams.include?(dsid) ? datastreams[dsid] : add_external_datastream(dsid)

      unless ds.external?
        raise ArgumentError, "Cannot add external file to datastream with controlGroup \"#{ds.controlGroup}\"" 
      end

      if ds.dsLocation_changed?
        raise DulHydra::Error, "Cannot add external file to datastream when dsLocation change is pending."
      end

      # Set the MIME type
      # The :mime_type option will be present when called from `add_file`.
      # The fallback is there in case `add_external_file` is called directly.
      ds.mimeType = opts[:mime_type] || DulHydra::Utils.mime_type_for(file, file_path)

      # Copy the file to storage unless we're using the original
      if opts[:use_original]
        raise DulHydra::Error, "Cannot add file to repository that is owned by another user." unless File.owned?(file_path)
        store_path = file_path
      else
        # generate new storage path for file
        store_path = create_external_file_path!
        # copy the original file to the storage location
        FileUtils.cp file_path, store_path
      end

      # set appropriate permissions on the file
      set_external_file_permissions!(store_path)

      # set dsLocation to file URI for storage path
      ds.dsLocation = DulHydra::Utils.path_to_uri(store_path)
    end

    # Create directory (if necessary) for newly generated file path and return path
    def create_external_file_path!
      file_path = generate_external_file_path
      FileUtils.mkdir_p(File.dirname(file_path))
      file_path
    end

    #
    # Generates a new external file storage location
    #
    # => {external_file_store}/1/e/69/1e691815-0631-4f9b-8e23-2dfb2eec9c70
    #
    def generate_external_file_path
      file_name = generate_external_file_name
      File.join(external_file_store, generate_external_directory_subpath(file_name), file_name)
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

    FileToAdd = Struct.new(:file, :dsid, :original_name)

    def virus_scan_results
      @virus_scan_results ||= []
    end

    def virus_scan
      file = file_to_add[:file]
      if DulHydra::Utils.file_or_path?(file) # can't virus scan blob
        virus_scan_results << DulHydra::Services::Antivirus.scan(file) 
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

    def generate_external_file_name
      SecureRandom.uuid      
    end

    def generate_external_directory_subpath(file_name)
      m = DulHydra.external_file_subpath_regexp.match(file_name)
      raise "File name does not match external file subpath pattern: #{file_name}" unless m
      subpath_segments = m.to_a[1..-1]
      File.join *subpath_segments
    end

    def cleanup_external_files_on_destroy
      paths = external_datastream_file_paths
      yield
      File.unlink *paths
    end

  end
end
