module DulHydra
  module Controller
    module HasStructuralMetadataBehavior
      extend ActiveSupport::Concern

      included do
        self.tabs.insert -2, :tab_structural_metadata
      end

      protected

      def tab_structural_metadata
        Tab.new("structural_metadata")
      end

    end
  end
end
