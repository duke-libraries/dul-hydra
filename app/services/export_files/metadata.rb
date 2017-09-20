require 'csv'

module ExportFiles
  class Metadata

    HEADERS = %i( repo_id object_type permanent_id local_id content_type original_filename )

    attr_reader :package

    delegate :finder, to: :package

    def initialize(package)
      @package = package
    end

    def csv
      CSV.generate("", headers: HEADERS, write_headers: true) do |rows|
        finder.results.each do |result|
          rows << [ result.id,
                    result.active_fedora_model,
                    result.permanent_id,
                    result.local_id,
                    result.media_type,
                    result["admin_metadata__original_filename_ssi"],
                  ]
        end
      end
    end

  end
end
