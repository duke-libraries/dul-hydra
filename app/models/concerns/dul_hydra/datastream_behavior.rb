module DulHydra
  module DatastreamBehavior

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
      if path = file_path
        File.basename(path)
      end
    end

  end
end
