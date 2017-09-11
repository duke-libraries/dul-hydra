module ExportFiles
  class PayloadFilePackager

    PAYLOAD_PATH = "objects"

    attr_reader :package, :payload_file

    delegate :source_path, :content, :parent, :master_file?,
             :original_filename, :default_filename,
             :content_digest,
             to: :payload_file
    delegate :add_file, :data_dir, to: :package

    def self.call(*args)
      new(*args).call
    end

    def initialize(package, payload_file)
      @package = package
      @payload_file = payload_file
    end

    def copyable?
      !!source_path
    end

    def call
      copyable? ? copy : download
      verify_checksum
    end

    def copy
      add_file(destination_path, source_path)
    end

    def download
      add_file(destination_path) do |io|
        io.binmode
        io.write(content)
      end
    end

    def destination_path
      File.join(PAYLOAD_PATH, nested_path || parent_path || default_path)
    end

    def nested_path
      if parent.respond_to?(:nested_path)
        parent.nested_path
      end
    end

    def parent_path
      if parent
        File.join(parent_path_element, default_path)
      end
    end

    def default_path
      if master_file? && original_filename
        original_filename
      else
        default_filename
      end
    end

    def parent_path_element
      parent_id = parent.local_id || parent.id
      Storage.sanitize_path(parent_id)
    end

    def verify_checksum
      FileUtils.cd(data_dir) do
        computed_digest = content_digest.type.file(destination_path).hexdigest
        if content_digest.value != computed_digest
          raise Ddr::Models::ChecksumInvalid, payload_file.to_s
        end
      end
    end

  end
end
