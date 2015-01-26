# Common behavior for repository object controllers
module DulHydra
  module Controller
    module RepositoryBehavior
      extend ActiveSupport::Concern

      included do
        # Order is important!
        layout :dul_hydra_layout
        load_and_authorize_resource instance_name: :current_object
        attr_reader :current_object

        include Blacklight::Base
        include DulHydra::Controller::TabbedViewBehavior
        include DulHydra::Controller::EventBehavior
        include DulHydra::Controller::CreatableBehavior
        include DulHydra::Controller::DescribableBehavior
        include DulHydra::Controller::RightsBehavior

        self.tabs = [:tab_descriptive_metadata,
                     :tab_permissions]

        helper_method :current_object
        helper_method :current_document
        helper_method :current_bookmarks
        helper_method :get_solr_response_for_field_values

        copy_blacklight_config_from CatalogController
      end

      def show
      end

      protected

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
          current_user.bookmarks_for_documents(@response ? @response.documents << current_document : [current_document])
      end

    end
  end
end
