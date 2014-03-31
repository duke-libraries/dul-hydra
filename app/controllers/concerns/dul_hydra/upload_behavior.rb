module DulHydra
  module UploadBehavior
    extend ActiveSupport::Concern

    included do
      rescue_from DulHydra::ChecksumInvalid, with: :checksum_invalid
    end

    protected

    def checksum_invalid exception
      flash.now[:error] = "<strong>Checksum invalid:</strong> #{exception.message}".html_safe
      render case params[:action]
             when "create" then :new
             when "update" then :edit
             else params[:action]
             end
    end

    def upload_content_to asset
      asset.upload content_to_upload, checksum: checksum
    end

    def upload_content_to! asset
      upload_to(asset) && asset.save
    end

    def content_to_upload
      @content_to_upload ||= params.require(content_param)
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
