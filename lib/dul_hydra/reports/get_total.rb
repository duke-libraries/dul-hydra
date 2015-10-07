module DulHydra::Reports
  class GetTotal < SimpleDelegator

    def call
      get_solr_response(solr_params)["response"]["numFound"]
    end

    def solr_params
      solr_query_params
        .merge(wt: "json",
               rows: 0,
               facet: "false")
    end

  end
end
