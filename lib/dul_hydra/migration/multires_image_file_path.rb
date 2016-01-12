module DulHydra::Migration
  class MultiresImageFilePath < Migrator

    # source: Rubydora::DigitalObject
    # target: AF::Base

    def migrate
      if multiresImage && multiresImage.external? && multiresImage.has_content?
        target.multires_image_file_path = URI.parse(multiresImage.dsLocation).path
      end
    end

    def multiresImage
      source.datastreams["multiresImage"]
    end

  end
end
