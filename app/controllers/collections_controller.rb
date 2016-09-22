class CollectionsController < ApplicationController

  include DulHydra::Controller::RepositoryBehavior
  include DulHydra::Controller::HasChildrenBehavior
  include DulHydra::Controller::HasAttachmentsBehavior
  include DulHydra::Controller::HasTargetsBehavior

  before_action :set_desc_metadata, only: :create
  self.tabs += [ :tab_actions ]
  respond_to :csv

  def items
    get_children
  end

  def export
    respond_to do |format|
      format.html { render :export }
      format.csv do
        case params[:type]
        when "descmd"
          export_metadata
        when "techmd"
          export_techmd
        else
          render nothing: true, status: 404
        end
      end
    end
  end

  protected

  def export_metadata
    scope = params.require(:scope)
    dmd_fields = Ddr::Index::Fields.descmd.dup
    unless params["dmd_fields"].blank?
      dmd_fields.select! { |f| params["dmd_fields"].include?(f.base) }
    end
    amd_fields = params["amd_fields"].map { |f| Ddr::Index::Fields.get(f) }
    all_fields = [:id, :active_fedora_model] + amd_fields + dmd_fields.sort
    models = params.require("models")
    query = Ddr::Index::Query.build(current_object) do |coll|
      case scope
      when "collection"
        is_governed_by coll
      when "admin_set"
        field :is_governed_by
        join from: :internal_uri, to: :is_governed_by, where: { admin_set: coll.admin_set }
      end
      model *models
      fields *all_fields
    end
    filename = case scope
               when "collection"
                 current_object.pid.sub(/:/, '-')
               when "admin_set"
                 current_object.admin_set
               end
    csv = query.csv
    csv.delete_empty_columns! if params[:remove_empty_columns]
    render csv: csv, filename: filename
  end

  def export_techmd
    query = Ddr::Index::Query.build(current_object) do |coll|
      is_governed_by coll
      has_content
      fields :id, :local_id, Ddr::Index::Fields.techmd
    end
    filename = current_object.pid.sub(/:/, '-')
    render csv: query.csv, filename: filename
  end

  def admin_metadata_fields
    super + [:admin_set, :research_help_contact]
  end

  def tab_actions
    Tab.new("actions")
  end

end
