module DulHydra
  module Controller
    module HasContentBehavior
      extend ActiveSupport::Concern

      included do
        rescue_from DulHydra::ChecksumInvalid, with: :checksum_invalid
        require_permission! :upload, only: :upload
        before_action :upload_content, only: :create
        self.log_actions << :upload
      end

      def upload
        if request.get?
          content_warning
        elsif request.patch?
          if upload_content!
            flash[:success] = "Content successfully uploaded."
            redirect_to action: "show"
          else
            render :upload
          end
        end
      end

      protected

      def upload_content
        current_object.upload content, checksum: checksum
      end

      def upload_content!
        current_object.upload! content, checksum: checksum
      end

      def content_warning
        if current_object.has_content?
          flash.now[:error] = "<strong>Warning!</strong> #{I18n.t('dul_hydra.upload.alerts.has_content')}".html_safe
        end
      end

      def checksum_invalid exception
        flash.now[:error] = "<strong>Checksum invalid:</strong> #{exception.message}".html_safe
        render case params[:action]
               when "create" then :new
               when "update" then :edit
               else params[:action]
               end
      end

      def content
        @content ||= params[content_param]
      end

      def checksum
        (params[checksum_param] || "").strip
      end

      def content_param
        :content
      end

      def checksum_param
        :checksum
      end

    end
  end
end
