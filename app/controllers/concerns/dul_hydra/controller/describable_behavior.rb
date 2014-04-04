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
          if current_object.update create_params
            flash[:success] = "Object successfully created"
            redirect_to action: "show", id: current_object
          else
            render :new
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
