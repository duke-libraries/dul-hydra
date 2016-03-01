class CollectionsController < ApplicationController

  include DulHydra::Controller::RepositoryBehavior
  include DulHydra::Controller::HasChildrenBehavior
  include DulHydra::Controller::HasAttachmentsBehavior
  include DulHydra::Controller::HasTargetsBehavior
  include DulHydra::Controller::PublicationBehavior

  before_action :set_desc_metadata, only: :create
  self.tabs += [ :tab_reports, :tab_actions ]

  def items
    get_children
  end

  def report
    respond_to do |format|
      format.csv do
        rep = case report_type
              when "descmd"
                DulHydra::Reports::CollectionDescriptiveMetadataReport.new(current_object)
              when "techmd"
                DulHydra::Reports::CollectionTechnicalMetadataReport.new(current_object)
              else
                render nothing: true, status: 404
              end
        csv = rep.run
        send_data csv.to_s, type: "text/csv", filename: rep.filename
      end
    end
  end

  protected

  def report_type
    type = params.require(:type)
  end

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
