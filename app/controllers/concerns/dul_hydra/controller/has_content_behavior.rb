module DulHydra
  module Controller
    module HasContentBehavior
      extend ActiveSupport::Concern

      included do
        self.log_actions << :upload
      end

      def create
        upload_content
        if current_object.save
          validate_checksum
          flash[:success] = "New #{current_object.class.to_s} created."
          redirect_to after_create_redirect
        else
          render :new
        end
      end

      def upload
        if request.patch?
          upload_content
          if current_object.save
            validate_checksum
            flash[:success] = I18n.t('dul_hydra.upload.alerts.success')
            redirect_to(action: "show") and return
          end
        end
      end

      protected

      def upload_content
        current_object.upload content_params[:file]
      end

      def validate_checksum
        return if content_params[:checksum].blank? || current_object.errors.any?
        checksum, checksum_type = content_params.values_at :checksum, :checksum_type
        current_object.validate_checksum! checksum, checksum_type
      rescue DulHydra::ChecksumInvalid => e
        flash[:error] = e.message
      else
        flash[:info] = "The checksum provided [#{checksum_type}: #{checksum}] was validated against the repository content."
      end

      def content_params
        return @content_params if @content_params
        @content_params = params.require(:content)
        @content_params.require(:file)
        @content_params.permit(:checksum, :checksum_type)
        @content_params
      end

      def checksum_invalid exception
        
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
