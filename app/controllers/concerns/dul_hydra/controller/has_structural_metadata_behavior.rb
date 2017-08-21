module DulHydra
  module Controller
    module HasStructuralMetadataBehavior
      extend ActiveSupport::Concern

      included do
        self.tabs.insert -2, :tab_structural_metadata
      end

      protected

      def tab_structural_metadata
        Tab.new("structural_metadata",
                actions: [
                    TabAction.new("generate_structure",
                                  url_for(action: "generate_structure"),
                                  can?(:generate_structure, current_object))
                ]
        )
      end

    end
  end
end
