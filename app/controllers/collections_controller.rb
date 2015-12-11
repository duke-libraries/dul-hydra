class CollectionsController < ApplicationController

  include DulHydra::Controller::RepositoryBehavior
  include DulHydra::Controller::HasChildrenBehavior
  include DulHydra::Controller::HasAttachmentsBehavior
  include DulHydra::Controller::HasTargetsBehavior

  before_action :set_desc_metadata, only: :create
  self.tabs += [ :tab_reports, :tab_actions ]

  def items
    get_children
  end

  def report
    respond_to do |format|
      format.csv do
        rep = DulHydra::Reports::Report.new
        basename = current_object.title_display.gsub /[^\w\.\-]/, "_"
        case params.require(:type)
        when "techmd"
          rep.filters << DulHydra::Reports::IsGovernedByFilter.new(current_object.pid)
          rep.filters << DulHydra::Reports::HasContentFilter
          rep.columns += DulHydra::Reports::Columns::TechnicalMetadata
          basename += "__TECHMD"
        when "descmd"
          rep.filters << DulHydra::Reports::IsMemberOfCollectionFilter.new(current_object.pid)
          rep.columns += DulHydra::Reports::Columns::DescriptiveMetadata
          basename += "__DESCMD"
        end
        csv = rep.run
        filename = basename + ".csv"
        send_data csv.read, type: "text/csv", filename: filename
      end
    end
  end

  protected

  def admin_metadata_fields
    super + [:admin_set, :research_help_contact]
  end

  def tab_reports
    Tab.new("reports",
            guard: can?(:report, current_object)
           )
  end

  def tab_actions
    Tab.new("actions")
  end

end
