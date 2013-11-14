module DulHydra::Models
  module Licensable
    extend ActiveSupport::Concern

    included do
      delegate :license_title, to: DulHydra::Datastreams::RIGHTS_METADATA, at: [:license, :title], multiple: false
      delegate :license_description, to: DulHydra::Datastreams::RIGHTS_METADATA, at: [:license, :description], multiple: false
      delegate :license_url, to: DulHydra::Datastreams::RIGHTS_METADATA, at: [:license, :url], multiple: false
    end

    def license
      if license_title or license_description or license_url
        {title: license_title, description: license_description, url: license_url}
      end
    end


  end
end
