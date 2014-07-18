module DulHydra
  module Controller
    module HasContentBehavior
      extend ActiveSupport::Concern

      included do
        rescue_from DulHydra::ChecksumInvalid, with: :checksum_invalid
        before_action :upload_content, only: :create
        self.log_actions << :upload
      end

      def upload
        if request.patch?
          upload_content
          if current_object.save
            flash[:success] = I18n.t('dul_hydra.upload.alerts.success')
            redirect_to(action: "show") and return
          end
        end
      end

      protected

      def upload_content
        current_object.upload content_params[:file], checksum: checksum_param
      end

      def content_params
        @content_params ||= params.require(:content).permit(:file, :checksum)
      end

      def checksum_invalid exception
        flash.now[:error] = "<strong>Checksum invalid:</strong> #{exception.message}".html_safe
        render case params[:action].to_sym
               when :create then :new
               when :update then :edit
               else params[:action]
               end
      end

      def checksum_param
        (content_params[:checksum] || "").strip
      end

    end
  end
end
