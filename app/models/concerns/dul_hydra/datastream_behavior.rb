module DulHydra
  module DatastreamBehavior

    DEFAULT_FILE_EXTENSION = "bin"

    # Returns a list of the external file paths for all versions of the datastream.
    def file_paths
      raise "The `file_paths' method is valid only for external datastreams." unless external?
      return Array(file_path) if new?
      versions.map(&:file_path).compact
    end

    # Returns the external file path for the datastream.
    # Returns nil if dsLocation is not a file URI.
    def file_path
      raise "The `file_path' method is valid only for external datastreams." unless external?
      DulHydra::Utils.path_from_uri(dsLocation) if DulHydra::Utils.file_uri?(dsLocation)
    end

    # Returns the file name of the external file for the datastream.
    # See #external_datastream_file_path(ds)
    def file_name
      raise "The `file_name' method is valid only for external datastreams." unless external?
      File.basename(file_path) rescue nil
    end

    # Returns the 
    def file_size
      raise "The `file_size' method is valid only for external datastreams." unless external?
      File.size(file_path) rescue nil
    end

    # Return default file extension for datastream based on MIME type
    def default_file_extension
      mimetypes = MIME::Types[mimeType]
      mimetypes.empty? ? DEFAULT_FILE_EXTENSION : mimetypes.first.extensions.first
    end

    # Return default file name prefix based on object PID
    def default_file_prefix
      [pid.sub(/:/, '_'), dsid].join("_")
    end

    # Return default file name
    def default_file_name
      [default_file_prefix, default_file_extension].join(".")
    end

  end
end
