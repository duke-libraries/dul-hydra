module DulHydra
  module Controller
    module HasContentBehavior
      extend ActiveSupport::Concern

      included do
        before_action :upload_content, only: :create
        self.tabs.unshift :tab_content_info
      end

      def upload
        if request.patch?
          begin
            upload_content
          rescue ActionController::ParameterMissing => e
            flash.now[:error] = ( e.param == :file ? "File is required." : e.to_s )
          else
            if current_object.save
              notify_upload
              validate_checksum
              flash[:success] = I18n.t('dul_hydra.upload.alerts.success')
              redirect_to(action: "show") and return
            end
          end
        end
      end

      protected

      def notify_upload
        notify_update(summary: "Object content was updated")
      end

      def upload_content
        current_object.upload content_params[:file]
      end

      def after_create_success
        validate_checksum
      end

      def validate_checksum
        return if content_params[:checksum].blank?
        flash[:info] = current_object.validate_checksum!(*checksum_params)
      rescue Ddr::Models::ChecksumInvalid => e
        flash[:error] = e.message
      end

      def content_params
        @content_params ||= params.require(:content).tap do |p|
          p.require(:file)
          p.permit(:checksum, :checksum_type)
        end
      end

      def checksum_params
        content_params.values_at :checksum, :checksum_type
      end

      def tab_content_info
        Tab.new("content_info",
                actions: [
                          TabAction.new("download",
                                        url_for(controller: "downloads", action: "show", id: current_object),
                                        current_object.has_content? && can?(:download, current_object)
                                        ),
                          TabAction.new("upload",
                                        url_for(action: "upload"),
                                        can?(:upload, current_object)
                                        )
                         ]
                )

      end

    end
  end
end
