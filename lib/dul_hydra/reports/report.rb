require "csv"

module DulHydra::Reports
  class Report

    class_attribute :csv_sep, :csv_mv_sep, :csv_quote
    self.csv_sep    = CSV::DEFAULT_OPTIONS[:col_sep]
    self.csv_mv_sep = "|"
    self.csv_quote  = CSV::DEFAULT_OPTIONS[:quote_char]

    class_attribute :query, :columns, :filters
    self.query   = "*:*"
    self.columns = [ Columns::PID ]
    self.filters = [ ]

    attr_writer :headers

    def run
      data = GetResults.new(self).call
      CSV.new(data,
              headers: headers,
              return_headers: true,
              write_headers: true,
              col_sep: csv_sep,
              quote_char: csv_quote
             )
    end

    def to_csv
      run.read
    end

    def headers
      @headers || columns.map(&:header)
    end

    def fields
      columns.map(&:to_s)
    end

    def csv_opts
      { :"csv.header"       => "false",
        :"csv.separator"    => csv_sep,
        :"csv.mv.separator" => csv_mv_sep,
        :"csv.encapsulator" => csv_quote,
      }
    end

    def filter_query
      filters.map(&:clauses).flatten
    end

    def solr_query_params
      { q: query, fq: filter_query }
    end

    def get_solr_response(solr_params)
      uri = URI(index_url(solr_params))
      http_response = Net::HTTP.get_response(uri)
      if http_response.content_type == "application/json"
        JSON.parse http_response.body
      else
        http_response.body
      end
    end

    private

    def index_url(solr_params)
      "%{base_url}/select?%{qs}" % {
        base_url: ActiveFedora.solr_config[:url],
        qs: URI.encode_www_form(solr_params)
      }
    end

  end
end
