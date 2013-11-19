module DulHydra::Models
  module Licensable
    extend ActiveSupport::Concern

    included do
      delegate :license_title, to: DulHydra::Datastreams::RIGHTS_METADATA, at: [:license, :title], multiple: false
      delegate :license_description, to: DulHydra::Datastreams::RIGHTS_METADATA, at: [:license, :description], multiple: false
      delegate :license_url, to: DulHydra::Datastreams::RIGHTS_METADATA, at: [:license, :url], multiple: false
    end

    def license
      if license_title.present? or license_description.present? or license_url.present?
        {title: license_title, description: license_description, url: license_url}.with_indifferent_access
      end
    end
    
    def license=(new_license)
      raise ArgumentError unless new_license.is_a?(Hash)
      l = new_license.with_indifferent_access
      self.license_title = l[:title]
      self.license_description = l[:description]
      self.license_url = l[:url]
    end

  end
end
