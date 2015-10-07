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
                  TabAction.new("struct_map_xml",
                                download_path(current_object, "structMetadata"),
                                show_ds_download_link?(current_object.structMetadata)
                               ),
                ]
               )
      end

    end
  end
end
