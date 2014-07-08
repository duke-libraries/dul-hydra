module DulHydra
  module Controller
    module DescribableBehavior
      extend ActiveSupport::Concern

      included do
        self.log_actions << :update
      end

      def edit
      end

      def update
        current_object.set_desc_metadata desc_metadata_params
        if current_object.save
          flash[:success] = "Descriptive metadata updated."
          redirect_to action: "show", tab: "descriptive_metadata"
        else
          render :edit
        end
      end

      protected

      def desc_metadata_params
        permitted = current_object.desc_metadata_terms.each_with_object({}) { |term, memo| memo[term] = [] }
        params.require(:descMetadata).permit(permitted)
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
