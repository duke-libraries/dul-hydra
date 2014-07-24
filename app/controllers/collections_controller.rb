class CollectionsController < ApplicationController

  include DulHydra::Controller::RepositoryBehavior
  include DulHydra::Controller::HasChildrenBehavior
  include DulHydra::Controller::HasAttachmentsBehavior

  self.tabs << :tab_collection_info

  helper_method :collection_report

  def items
    get_children
  end
  
  # HTML format intended for tab content loaded via ajax
  def collection_info
    respond_to do |format|
      format.html { render layout: false }
      format.csv do
        filename = "#{current_object.title_display.gsub(/[^\w]/, '_')}.csv"
        send_data collection_csv_report, type: "text/csv", filename: filename
      end
    end
  end

  protected

  def create_params
    {admin_policy_id: params.require(:admin_policy_id)}.merge params.require(:descMetadata).permit(title: [])
  end

  def set_admin_policy
    if params[:admin_policy_id].present?
      current_object.admin_policy = AdminPolicy.find(params[:admin_policy_id])
    end
  end

  def collection_report
    return @collection_report if @collection_report
    components = current_object.components_from_solr
    total_file_size = components.map(&:content_size).reduce(0, :+)
    @collection_report = {
      components: components.size,
      items: current_object.children.size,
      total_file_size: total_file_size
    }
  end

  def collection_csv_report
    CSV.generate do |csv|
      csv << DulHydra.collection_report_fields.collect {|f| f.to_s.upcase}
      current_object.components_from_solr.each do |doc|
        csv << DulHydra.collection_report_fields.collect {|f| doc.send(f)}
      end
    end
  end

  # tabs

  def tab_collection_info
    Tab.new("collection_info", href: url_for(action: "collection_info"))
  end

end
