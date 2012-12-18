require 'mime/types'

module DulHydra::Models
  module Fooable
    extend ActiveSupport::Concern

    DEFAULT_MIME_TYPE = "application/octet-stream"

    included do
      has_file_datastream :name => "digitizationguide", :type => DulHydra::Datastreams::FileContentDatastream
      has_file_datastream :name => "fmpexport", :type => DulHydra::Datastreams::FileContentDatastream
    end

  end
end
