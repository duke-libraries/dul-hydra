module DulHydra
  module Controller
    module DescribableBehavior
      extend ActiveSupport::Concern

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

      protected

      def set_desc_metadata
        current_object.set_desc_metadata desc_metadata_params
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
                          TabAction.new("download",
                                        datastream_download_url_for("descMetadata"),
                                        show_ds_download_link?(current_object.descMetadata))
                         ]
                )
      end

    end
  end
end
