require 'bagit'
require 'uri'

module ExportFiles
  class Package
    include ActiveModel::Validations

    METADATA_FILENAME = "METADATA.csv"

    attr_reader :archive, :finder, :basename

    delegate :bag_files, :data_dir, :add_file, :manifest!, to: :bag
    delegate :path, to: :storage
    delegate :repo_ids, :content_ids, :identifiers, :not_found, :results,
             to: :finder

    validates_presence_of :identifiers, :basename
    validates :expected_payload_size, numericality: { less_than: DulHydra.export_files_max_payload_size }
    validates_presence_of :results,  message: "payload is empty (identifiers not found or access denied)"

    def self.call(*args)
      new(*args).tap do |pkg|
        pkg.export!
      end
    end

    def initialize(identifiers, ability: nil, basename: nil)
      @basename = basename.to_s.strip
      @finder = Finder.new(identifiers, ability: ability)
    end

    def export!
      add_payload_files
      add_metadata
      manifest!
      archive!
    end

    def storage
      @storage ||= Storage.call(basename)
    end

    def bag
      @bag ||= BagIt::Bag.new(path)
    end

    def archive!
      @archive = Archive.call(self)
    end

    def metadata
      @metadata ||= Metadata.new(self)
    end

    def archived?
      !!archive
    end

    def url
      if archived?
        base_url + archive.path.sub("#{Storage.store}/", "")
      end
    end

    def base_url
      u = DulHydra.export_files_base_url
      if DulHydra.host_name
        u = [ "https://", DulHydra.host_name, u ].join
      end
      u
    end

    def payload_size
      bag_files.map { |f| File.size(f) }.reduce(:+)
    end

    def add_metadata
      add_file(METADATA_FILENAME) { |io| io.write(metadata.csv) }
    end

    def add_payload_files
      payload_files.each { |payload_file| add_payload_file(payload_file) }
    end

    def add_payload_file(payload_file)
      PayloadFilePackager.call(self, payload_file)
    end

    def expected_payload_size
      finder.total_content_size
    end

    def expected_num_files
      finder.num_files
    end

    def payload_files
      Enumerator.new do |e|
        finder.objects.each do |obj|
          e << PayloadFile.new(obj, obj.content)
        end
      end
    end

  end
end
