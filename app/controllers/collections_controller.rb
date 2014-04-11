class CollectionsController < ApplicationController

  include DulHydra::Controller::RepositoryBehavior
  include DulHydra::Controller::HasChildrenBehavior
  include DulHydra::Controller::HasAttachmentsBehavior

  self.tabs.unshift :tab_items
  self.tabs << :tab_collection_info

  require_read_permission! only: :collection_info
  before_action :set_admin_policy, only: :create
  helper_method :collection_report

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

  def set_admin_policy
    current_object.admin_policy = AdminPolicy.find(params[:admin_policy_id])
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


end
