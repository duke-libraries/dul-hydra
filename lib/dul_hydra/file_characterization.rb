require "resque"

module DulHydra
  class FileCharacterization

    class << self
      def default_limit
        @default_limit || 1000
      end

      def call(limit = nil)
        new(limit).call
      end
    end

    attr_reader :limit, :job

    delegate :queued_object_ids, to: :job

    def initialize(limit = nil)
      @limit = (limit || self.class.default_limit).to_i
      @job = Ddr::Jobs::FitsFileCharacterization
    end

    # @return [Fixnum] the number of file characterization jobs queued
    def call
      queued = 0
      query.pids.each do |pid|
        next if queued_object_ids.include?(pid)
        Resque.enqueue(job, pid)
        queued += 1
      end
      queued
    end

    private

    def query
      Ddr::Index::QueryBuilder.build do |builder|
        builder
          .filter(Ddr::Index::Filters::HAS_CONTENT)
          .absent(Ddr::Index::Fields::TECHMD_FITS_VERSION)
          .fields("id")
          .desc(Ddr::Index::Fields::OBJECT_CREATE_DATE)
          .limit(limit)
      end
    end

  end
end
