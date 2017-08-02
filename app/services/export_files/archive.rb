module ExportFiles
  class Archive

    attr_reader :dirname, :zipname, :path

    def self.call(package)
      new(package).call
    end

    def initialize(package)
      @dirname, @zipname = File.split(package.path)
    end

    def call
      zip!
      self
    end

    def zip!
      FileUtils.cd(dirname) do
        if system("zip", "-mqr", zipname, zipname)
          @path = File.join(dirname, "#{zipname}.zip")
        else
          raise "Error creating zip archive."
        end
      end
    end

    def size
      File.size(path)
    end

    def md5
      Digest::MD5.file(path).hexdigest
    end

  end
end
