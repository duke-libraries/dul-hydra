# Common behavior for repository object controllers
module DulHydra
  module Controller
    module RepositoryBehavior
      extend ActiveSupport::Concern

      included do
        layout :dul_hydra_layout

        load_resource instance_name: :current_object
        before_action :after_load_before_authorize, only: [:new, :create]
        before_action :log_current_object
        authorize_resource instance_name: :current_object

        attr_reader :current_object

        include Blacklight::Base
        include DulHydra::Controller::TabbedViewBehavior

        self.tabs = [ :tab_descriptive_metadata, :tab_admin_metadata, :tab_roles, :tab_duracloud ]

        helper_method :current_object
        helper_method :current_document
        helper_method :current_bookmarks
        helper_method :get_solr_response_for_field_values
        helper_method :admin_metadata_fields

        copy_blacklight_config_from CatalogController
      end

      def create
        current_object.grant_roles_to_creator(current_user)
        if save_current_object
          flash[:success] = after_create_success_message
          after_create_success
          redirect_to after_create_redirect
        else
          render :new
        end
      end

      def update
        begin
          set_desc_metadata
        rescue ActionController::ParameterMissing
          current_object.errors.add(:base, t('dul_hydra.tabs.descriptive_metadata.errors.empty_form_submission'))
        end
        if current_object.errors.empty? && save_current_object(summary: "Descriptive metadata updated")
          flash[:success] = "Descriptive metadata updated."
          redirect_to action: "show", tab: "descriptive_metadata"
        else
          render :edit
        end
      end

      def roles
        if request.patch?
          current_object.roles.replace *submitted_roles
          if save_current_object(summary: "Roles updated")
            flash[:success] = "Roles successfully updated"
            redirect_to(action: "show", tab: "roles") and return
          end
        end
      end

      def events
        @events = current_object.events.reorder("event_date_time DESC")
      end

      def event
        @event = Ddr::Events::Event.find(params[:event_id])
      end

      def admin_metadata
        if request.patch?
          set_admin_metadata
          if save_current_object(summary: "Administrative metadata updated")
            flash[:success] = "Administrative metadata successfully updated."
            redirect_to(action: "show", tab: "admin_metadata") and return
          end
        end
      end

      def duracloud
        if request.xhr?
          @tab = tab_duracloud
          @manifest = Duracloud::Fcrepo3ObjectManifest.new(current_object)
          render "duracloud", layout: false
        else
         redirect_to action: "show", tab: "duracloud"
        end
      end

      protected

      # Controls what fields are displayed on the admin metadata tab and edit form
      def admin_metadata_fields
        [:local_id, :display_format, :ead_id, :aspace_id, :doi, :rights_note]
      end

      def admin_metadata_params
        params.require(:adminMetadata).tap do |p|
          p.select  { |k, v| v == "" }.each { |k, v| p[k] = nil }
          p.reject! { |k, v| current_object.send(k) == v }
          p.permit!
        end
      end

      def set_admin_metadata
        params.require(:adminMetadata).each do |term, value|
          current_object.adminMetadata.set_values(term, value)
        end
      end

      def after_load_before_authorize
        # no-op - override
      end

      def log_current_object
        logger.debug "CURRENT OBJECT: #{current_object.inspect}"
      end

      def dul_hydra_layout
        case params[:action].to_sym
        when :new, :create then 'new'
        else 'objects'
        end
      end

      def current_document
        @document ||= get_solr_response_for_doc_id(params[:id])[1]
      end

      # override Blacklight::CatalogHelperBehavior
      def current_bookmarks
        @current_bookmarks ||=
          current_user.bookmarks_for_documents(@response ? @response.documents + [current_document] : [current_document])
      end

      def after_create_success
        # no-op -- override to add behavior after save and before redirect
      end

      def after_create_success_message
        "New #{current_object.class.to_s} created."
      end

      def after_create_redirect
        {action: :edit, id: current_object}
      end

      def set_desc_metadata
        if Array(desc_metadata_params[:rights]).length > 1
          current_object.errors.add(:rights, "Cannot have multiple values.")
        end
        current_object.set_desc_metadata(desc_metadata_params)
      end

      def desc_metadata_params
        @desc_metadata_params ||= params.require(:descMetadata).permit(permitted_desc_metadata_params)
      end

      def permitted_desc_metadata_params
        current_object.desc_metadata_terms.each_with_object({}) { |term, memo| memo[term] = [] }
      end

      def tab_descriptive_metadata
        Tab.new("descriptive_metadata",
                actions: [
                  TabAction.new("edit",
                                url_for(action: "edit"),
                                can?(:edit, current_object)),
                  TabAction.new("download",
                                download_path(current_object, "descMetadata"),
                                show_ds_download_link?(current_object.descMetadata))
                ]
               )
      end

      def tab_roles
        Tab.new("roles",
                actions: [
                  TabAction.new("edit",
                                url_for(action: "roles"),
                                can?(:grant, current_object)),
                ]
               )
      end

      def tab_duracloud
        Tab.new("duracloud",
                href: url_for(id: current_object, action: "duracloud")
               )
      end

      def tab_admin_metadata
        Tab.new("admin_metadata",
                actions: [
                  TabAction.new("edit",
                                url_for(action: "admin_metadata"),
                                can?(:admin_metadata, current_object)),
                ]
               )
      end

      def submitted_roles
        Ddr::Auth::Roles::DetachedRoleSet.from_json(roles_param)
      end

      def roles_param
        params.require :roles
      end

      def save_current_object(options={})
        current_object.save(save_options(options))
      end

      def save_options(extra={})
        default_save_options.merge(extra)
      end

      def default_save_options
        { user: current_user, comment: params[:comment] }
      end

    end
  end
end
