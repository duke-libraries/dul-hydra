class CollectionsController < ApplicationController

  include DulHydra::Controller::RepositoryBehavior
  include DulHydra::Controller::HasChildrenBehavior
  include DulHydra::Controller::HasAttachmentsBehavior
  include DulHydra::Controller::HasTargetsBehavior

  before_action :set_desc_metadata, only: :create
  self.tabs << :tab_reports

  def items
    get_children
  end

  def report
    respond_to do |format|
      format.csv do
        rep = DulHydra::Reports::CollectionReport.new(params[:id])
        basename = current_object.title_display.gsub /[^\w\.\-]/, "_"
        case params.require(:type)
        when "techmd"
          rep.columns += DulHydra::Reports::Columns::TechnicalMetadata
          basename += "__TECHMD"
        end
        csv = rep.run
        filename = basename + ".csv"
        send_data csv.read, type: "text/csv", filename: filename
      end
    end
  end

  protected

  def tab_reports
    Tab.new("reports",
            guard: can?(:report, current_object)
           )
  end

end
