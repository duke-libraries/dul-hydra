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

        include Blacklight::Base # XXX probably not needed here
        include DulHydra::Controller::TabbedViewBehavior

        self.tabs = [ :tab_descriptive_metadata, :tab_admin_metadata, :tab_roles ]

        helper_method :current_object
        helper_method :current_document
        helper_method :current_bookmarks
        helper_method :get_solr_response_for_field_values
        helper_method :admin_metadata_fields

        copy_blacklight_config_from CatalogController
      end

      def new
      end

      def create
        current_object.grant_roles_to_creator(current_user)
        if current_object.save
          notify_creation
          flash[:success] = after_create_success_message
          after_create_success
          redirect_to after_create_redirect
        else
          render :new
        end
      end

      def show
      end

      def edit
      end

      def update
        begin
          set_desc_metadata
        rescue ActionController::ParameterMissing
          current_object.errors.add(:base, t('dul_hydra.tabs.descriptive_metadata.errors.empty_form_submission'))
        end
        if current_object.errors.empty? && current_object.save
          notify_update(summary: "Descriptive metadata updated")
          flash[:success] = "Descriptive metadata updated."
          redirect_to action: "show", tab: "descriptive_metadata"
        else
          render :edit
        end
      end

      def roles
        if request.patch?
          current_object.roles.replace *submitted_roles
          if current_object.save
            notify_update(summary: "Roles updated")
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
          current_object.attributes = admin_metadata_params
          changes = current_object.changes
          if changes.present?
            if current_object.save
              notify_update(
                summary: "Administrative metadata updated",
                detail: "Changed attributes:\n\n#{changes}"
              )
              flash[:success] = "Administrative metadata successfully updated."
              redirect_to(action: "show", tab: "admin_metadata") and return
            end
          else
            flash.now[:error] = "Administrative metadata not updated, as no values were changed.".html_safe
          end
        end
      end

      protected

      # Controls what fields are displayed on the admin metadata tab and edit form
      def admin_metadata_fields
        [:license, :local_id, :display_format, :ead_id]
      end      

      def admin_metadata_params
        params.require(:adminMetadata).tap do |p|
          p.select  { |k, v| v == "" }.each { |k, v| p[k] = nil }
          p.reject! { |k, v| current_object.send(k) == v }
          p.permit!
        end
      end

      def after_load_before_authorize
        # no-op - override
      end

      def log_current_object
        logger.debug "CURRENT OBJECT: #{current_object.model_and_id}"
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

      def notify_creation
        notify_event :creation
      end

      def after_create_success_message
        "New #{current_object.class.to_s} created."
      end

      def after_create_redirect
        {action: :edit, id: current_object}
      end

      def set_desc_metadata
        current_object.set_desc_metadata(desc_metadata_params)
      end

      def desc_metadata_params
        permitted = current_object.desc_metadata_terms.each_with_object({}) { |term, memo| memo[term] = [] }
        params.require(:descMetadata).permit(permitted)
      end

      def tab_descriptive_metadata
        Tab.new("descriptive_metadata",
                actions: [
                  TabAction.new("edit",
                                url_for(action: "edit"),
                                can?(:edit, current_object)),
                  # TODO fix or remove
                  # TabAction.new("download",
                  #               download_path(current_object, "descMetadata"),
                  #               show_ds_download_link?(current_object.descMetadata))
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

      def notify_event type, args={}
        args[:pid] ||= current_object.id
        args[:user_key] ||= current_user.user_key
        args.merge! event_params
        Ddr::Notifications.notify_event(type, args)
      end

      def notify_update args={}
        notify_event :update, args
      end

      def event_params
        params.permit(:comment)
      end

    end
  end
end
