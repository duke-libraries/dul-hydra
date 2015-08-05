module DulHydra::Reports
  module Filter

    attr_accessor :clauses

    private

    def raw_query(key, value)
      ActiveFedora::SolrService.raw_query(key, value)
    end

  end
end
