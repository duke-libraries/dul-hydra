# Common behavior for repository object controllers
module DulHydra
  module Controller
    module RepositoryBehavior
      extend ActiveSupport::Concern

      included do
        # The order of included modules is important!
        include Blacklight::Base
        include DulHydra::Controller::TabbedViewBehavior
        include DulHydra::Controller::Authorization
        include DulHydra::Controller::EventLogBehavior
        include DulHydra::Controller::DescribableBehavior
        include DulHydra::Controller::RightsBehavior

        # Default show tabs
        self.tabs = [:tab_descriptive_metadata,
                     :tab_permissions,
                     :tab_preservation_events]

        layout 'objects', except: [:new, :create]

        require_read_permission! only: :show
        before_action :set_initial_permissions, only: :create

        helper_method :current_object
        helper_method :current_document
        helper_method :get_solr_response_for_field_values
      end

      def show
      end

      protected

      def set_initial_permissions
        current_object.set_initial_permissions current_user
      end

      def current_object
        # :resource is defined by HydraEditor and included here through DescribableBehavior
        @current_object ||= (resource || ActiveFedora::Base.find(params[:id], cast: true))
      end

      def current_document
        @document ||= get_solr_response_for_doc_id[1]
      end

    end
  end
end
