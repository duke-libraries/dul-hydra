require 'json'

module DulHydra::Models
  module SolrDocument

    def object_profile
      JSON.parse(self[:object_profile_display].first)
    end

    def datastreams
      object_profile["datastreams"]
    end
    
    def has_datastream?(dsID)
      !(datastreams[dsID].nil? || datastreams[dsID].empty?)
    end

    def has_admin_policy?
      !admin_policy_uri.blank?
    end

    def admin_policy_uri
      get(:is_governed_by_s)
    end

    def admin_policy_pid
      uri = admin_policy_uri
      uri &&= ActiveFedora::Base.pids_from_uris(uri)
    end

    def has_parent?
      !parent_uri
    end

    def parent_uri
      get(:is_part_of_s) || get(:is_member_of_s) || get(:is_member_of_collection_s)
    end

    def parent_pid
      uri = parent_uri
      uri &&= ActiveFedora::Base.pids_from_uris(uri)
    end

    def active_fedora_model
      get(:active_fedora_model_s)
    end
    
    def has_thumbnail?
      has_datastream?(DulHydra::Datastreams::THUMBNAIL)
    end

    def has_content?
      has_datastream?(DulHydra::Datastreams::CONTENT)
    end

  end
end
