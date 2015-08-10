module DulHydra::Reports
  class GetResults < SimpleDelegator

    def call
      get_solr_response(solr_params)
    end

    def total
      GetTotal.new(self).call
    end

    def solr_params
      solr_query_params
        .merge(csv_opts)
        .merge(rows: total,
               wt: "csv",
               fl: fields)
    end

  end
end
