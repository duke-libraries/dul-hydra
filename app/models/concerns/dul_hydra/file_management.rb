module DulHydra
  module FileManagement
    extend ActiveSupport::Concern

    included do
      after_save :notify_virus_scan_results

      # Deleting the datastream external files on destroying the object can't 
      # be handled with a datastream around_destroy callback.
      # See https://groups.google.com/d/msg/hydra-tech/xJaZr2wVhbg/4iafvso98w8J
      around_destroy :cleanup_external_files_on_destroy
    end

    # Override Hydra::ModelMethods
    # XXX I would prefer the signature to be: add_file(file, dsid, opts={})
    def add_file file, dsid, file_name
      virus_scan(file) 
      mime_type = DulHydra::Utils.mime_type_for(file, file_name)
      if datastreams.include?(dsid) && datastreams[dsid].external?
        return add_external_file(file, dsid, file_name: file_name, mime_type: mime_type) 
      end
      add_file_datastream(file, dsid: dsid, mimeType: mime_type)
    end

    def add_external_file file, dsid, opts={}
      file_path = DulHydra::Utils.file_path(file) # raises ArgumentError

      # Retrieve or create the datastream
      datastream = datastreams.include?(dsid) ? datastreams[dsid] : add_external_datastream(dsid)

      raise DulHydra::Error, "Cannot add external file to datastream when dsLocation change is pending." if datastream.dsLocation_changed?

      # set the mime type
      datastream.mimeType = opts[:mime_type] || DulHydra::Utils.mime_type_for(file, file_path)

      # copy the file to storage unless we're using the original
      if opts[:use_original]
        store_path = file_path
      else
        # generate storage path
        file_name = opts[:file_name] || File.basename(file_path)
        store_path = generate_external_file_path(file_name)
        # create new directory
        FileUtils.mkdir_p File.dirname(store_path)
        # copy the original file to the storage location
        FileUtils.cp file_path, store_path
      end

      datastream.dsLocation = DulHydra::Utils.path_to_uri(store_path)
    end

    def external_datastream_file_paths ds=nil
      paths = []
      if ds
        raise ArgumentError, "Datastream not present on object \"#{pid}\": #{ds.inspect}" unless ds
        raise ArgumentError, "Datastream is not external: #{ds.inspect}" unless ds.external?
        ds.versions.each { |dsVersion| paths << external_datastream_file_path(dsVersion) }
      else # iterate over all external datastreams
        datastreams.values.select { |ds| ds.external? }.each do |ds|
          paths.concat external_datastream_file_paths(ds)
        end
      end
      paths.compact
    end

    def external_datastream_file_path ds
      raise ArgumentError, "Datastream is not external: #{ds.inspect}" unless ds.external?
      DulHydra::Utils.path_from_uri(ds.dsLocation) if DulHydra::Utils.file_uri?(ds.dsLocation)
    end

    def external_datastream_file_name ds
      path = external_datastream_file_path(ds)
      path ? File.basename(path) : nil
    end

    # This method essentially duplicates what ActiveFedora::Datastreams#add_file_datastream
    # does for adding a managed file datastream.
    def add_external_datastream dsid, opts={}
      options = {controlGroup: "E", dsLabel: "External file"}.merge(opts)
      klass = self.class.datastream_class_for_name(dsid)
      datastream = create_datastream(klass, dsid, options)
      add_datastream(datastream)
      self.class.build_datastream_accessor(dsid)
      datastream
    end

    protected

    def virus_scan_results
      @virus_scan_results ||= []
    end

    def notify_virus_scan_results
      while virus_scan_results.present?
        result = virus_scan_results.shift
        ActiveSupport::Notifications.instrument(DulHydra::Notifications::VIRUS_CHECK, result: result, pid: pid)
      end
    end

    def virus_scan file
      if DulHydra::Utils.file_or_path?(file) # can't virus scan blob
        virus_scan_results << DulHydra::Services::Antivirus.scan(file) 
      end
    end

    #
    # Generates a full path storage location for the file_name
    #
    # Example: file_name = "special.doc"
    # 
    # => {external_file_store}/1/e/69/1e691815-0631-4f9b-8e23-2dfb2eec9c70/special.doc
    #
    def generate_external_file_path file_name
      File.join(external_file_store, generate_external_file_subpath, file_name)
    end

    def external_file_store
      DulHydra.external_file_store
    end

    def generate_external_file_dirname
      SecureRandom.uuid      
    end

    def generate_external_file_subpath 
      dirname = generate_external_file_dirname
      m = DulHydra.external_file_subpath_regexp.match(dirname)
      subpath_segments = m.to_a[1..-1] << dirname
      File.join *subpath_segments
    end

    def cleanup_external_files_on_destroy
      paths = external_datastream_file_paths
      yield
      File.unlink *paths
    end

  end
end
