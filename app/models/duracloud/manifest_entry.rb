require "active_resource"

module Duracloud
  class ManifestEntry < ActiveResource::Base
    self.site = ENV["DDR_AUX_API_URL"]
    self.element_name = "duracloud/manifest_entry"

    def self.fcrepo3(space_id, object_uri)
      get(:fcrepo3, space_id: space_id, object_uri: object_uri).map { |e| new(e) }
    end
  end
end
