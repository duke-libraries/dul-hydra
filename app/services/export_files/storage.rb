require 'fileutils'

module ExportFiles
  class Storage

    SUBPATH_FORMAT = "%Y%m%d-%H%M%S-%L"
    DISALLOWED_CHARS = /[^\w\.\-]/

    def self.sanitize_path(path)
      path.gsub(DISALLOWED_CHARS, "_")
    end

    def self.generate_subpath
      Time.now.utc.strftime(SUBPATH_FORMAT)
    end

    def self.store
      DulHydra.export_files_store
    end

    def self.call(basename)
      new(basename).call
    end

    attr_reader :path

    def initialize(basename)
      @path = File.join(Storage.store,
                        Storage.generate_subpath,
                        Storage.sanitize_path(basename))
    end

    def call
      create! unless created?
      self
    end

    def create!
      FileUtils.mkdir_p(path)
    end

    def created?
      File.directory?(path)
    end

  end
end
