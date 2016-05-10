require "virtus"

module DulHydra::Reports
  class Report
    include Virtus.model

    attribute :query,    Ddr::Index::Query, default: Ddr::Index::Query.new
    attribute :title,    String,            default: :default_title

    def initialize(**args, &block)
      super
      if block_given?
        query.build &block
      end
    end

    # @return [Ddr::Index::CSVQueryResult]
    def run
      query.csv
    end

    def filename
      title.gsub(/[^\w\.\-]/, "_") + ".csv"
    end

    def default_title
      "Report"
    end

  end
end
