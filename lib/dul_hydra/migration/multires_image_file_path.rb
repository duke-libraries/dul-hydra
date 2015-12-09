module DulHydra::Migration
  class MultiresImageFilePath < Migrator

    # source: Rubydora::DigitalObject
    # target: AF::Base

    def migrate
      if multiresImage && multiresImage.external? && multiresImage.has_content?
        target.multires_image_file_path = multiresImage.dsLocation
      end
    end

    def multiresImage
      source.datastreams["multiresImage"]
    end

  end
end
