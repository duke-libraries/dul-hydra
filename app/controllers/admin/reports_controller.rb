module Admin
  class ReportsController < BaseController

    respond_to :csv

    def show
      report = DulHydra::Reports::Report.new
      filename = "Duke_Digital_Repository"
      case params.require(:type)
      when "techmd"
        report.filters << DulHydra::Reports::HasContentFilter
        report.columns += DulHydra::Reports::Columns::TechnicalMetadata
        filename += "__TECHMD"
      end
      render csv: report, filename: filename
    end

  end
end
