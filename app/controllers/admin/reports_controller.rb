module Admin
  class ReportsController < BaseController

    respond_to :csv

    def show
      filename = "Duke_Digital_Repository"
      case params.require(:type)
      when "techmd"
        query = Ddr::Index::Query.new do
          has_content
          fields :id, Ddr::Index::Fields.techmd
        end
        render csv: query.csv, filename: filename
      else
        render nothing: true, status: 404
      end
    end

  end
end
