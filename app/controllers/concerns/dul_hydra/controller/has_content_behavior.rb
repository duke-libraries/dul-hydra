module DulHydra
  module Controller
    module HasContentBehavior
      extend ActiveSupport::Concern

      included do
        before_action :upload_content, only: :create
        self.tabs.unshift :tab_tech_metadata
        self.tabs << :tab_files
        helper_method :tech_metadata_fields
      end

      def upload
        @dsid = params[:dsid] || request.params['content']['datastream']
        if request.patch?
          begin
            upload_file(content_params[:datastream])
          rescue ActionController::ParameterMissing => e
            flash.now[:error] = ( e.param == :file ? "File is required." : e.to_s )
          else
            if current_object.save(summary: "Object was updated with file")
              validate_checksum
              flash[:success] = I18n.t('dul_hydra.upload.alerts.success')
              redirect_to(action: "show") and return
            end
          end
        end
      end

      def files
        if request.xhr?
          # For async loading of tab content
          @tab = tab_files
          render "files", layout: false
        else
          redirect_to action: "show", tab: "files"
        end
      end

      protected

      def tech_metadata_fields
        DulHydra.techmd_show_fields.map do |field|
          [field, Array(current_object.techmd.send(field))]
        end.to_h
      end

      def upload_content
        upload_file(Ddr::Datastreams::CONTENT)
      end

      def upload_file(datastream)
        current_object.add_file content_params[:file], datastream
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
          p.require(:datastream)
          p.require(:file)
          p.permit(:checksum, :checksum_type)
        end
      end

      def checksum_params
        content_params.values_at :checksum, :checksum_type
      end

      def tab_tech_metadata
        Tab.new("tech_metadata",
                actions: [
                  TabAction.new("fits_xml",
                                download_path(current_object, "fits"),
                                show_ds_download_link?(current_object.fits)
                               ),
                ]
               )
      end

      def tab_files
        Tab.new("files",
                href: url_for(id: current_object, action: "files")
               )
      end

    end
  end
end
