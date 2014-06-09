# Provides descriptive metadata support
module DulHydra
  module Controller
    module DescribableBehavior
      extend ActiveSupport::Concern

      included do
        include RecordsControllerBehavior     # HydraEditor
        helper_method :resource_instance_name # HydraEditor method
        self.log_actions += [:create, :update]

        def new
          # Not using HydraEditor's :new action or template
          render layout: 'new'
        end

        def create
          params_to_use = create_params
          params_to_use.each { |k,v| params_to_use[k] = nil if v.empty? }
          if current_object.update params_to_use
            flash[:success] = I18n.t('dul_hydra.repository_objects.alerts.created')
            redirect_to action: "show", id: current_object
          else
            render :new, layout: 'new'
          end
        end

        protected

        # Overrides RecordsControllerBehavior
        def collect_form_attributes
          resource_params.reject { |key, value| resource[key].empty? and value == [""] }
        end

        # Overrides RecordsControllerBehavior
        def redirect_after_update
          url_for resource
        end
      end # included

      protected

      def resource_params
        params.require(resource_instance_name.to_sym)
      end

      def edit_params
        resource_params.permit(resource.terms_for_editing.each_with_object({}) {|term, h| h[term] = []})
      end

      def create_params
        resource_params.permit(:title, :description)
      end

      # tabs

      def tab_descriptive_metadata
        Tab.new("descriptive_metadata",
                actions: [
                          TabAction.new("edit",
                                        url_for(action: "edit"),
                                        can?(:edit, current_object)),
                          TabAction.new("download",
                                        datastream_download_url_for("descMetadata"),
                                        show_ds_download_link?(current_object.descMetadata))
                         ]
                )
      end

    end
  end
end

HydraEditor::ControllerResource.class_eval do
  # We don't want the behavior requiring the :type param,
  # just use normal CanCan::ControllerResources behavior.
  def resource_class
    super
  end
end
