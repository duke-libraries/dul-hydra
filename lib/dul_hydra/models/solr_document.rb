require 'json'

module DulHydra::Models
  module SolrDocument

    def object_profile
      @object_profile ||= JSON.parse(self[DulHydra::IndexFields::OBJECT_PROFILE].first)
    end

    def datastreams
      object_profile["datastreams"]
    end
    
    def has_datastream?(dsID)
      !datastreams[dsID].blank?
    end

    def has_admin_policy?
      !admin_policy_uri.blank?
    end

    def admin_policy_uri
      get(DulHydra::IndexFields::IS_GOVERNED_BY)
    end

    def admin_policy_pid
      uri = admin_policy_uri
      uri &&= ActiveFedora::Base.pids_from_uris(uri)
    end

    def has_parent?
      !parent_uri.blank?
    end

    def parent_uri
      get(DulHydra::IndexFields::IS_PART_OF) || get(DulHydra::IndexFields::IS_MEMBER_OF) || get(DulHydra::IndexFields::IS_MEMBER_OF_COLLECTION)
    end

    def parent_pid
      uri = parent_uri
      uri &&= ActiveFedora::Base.pids_from_uris(uri)
    end

    def active_fedora_model
      get(DulHydra::IndexFields::ACTIVE_FEDORA_MODEL)
    end

    def title
      get(DulHydra::IndexFields::TITLE)
    end

    def identifier
      get(DulHydra::IndexFields::IDENTIFIER)
    end
    
    def has_thumbnail?
      has_datastream?(DulHydra::Datastreams::THUMBNAIL)
    end

    def has_content?
      has_datastream?(DulHydra::Datastreams::CONTENT)
    end
    
    def targets
      object_uri = ActiveFedora::SolrService.escape_uri_for_query("info:fedora/#{id}")
      query = "#{DulHydra::IndexFields::IS_EXTERNAL_TARGET_FOR}:#{object_uri}"
      @targets ||= ActiveFedora::SolrService.query(query)
    end
    
    def has_target?
      targets.size > 0 ? true : false
    end
    
    def children
      object_uri = ActiveFedora::SolrService.escape_uri_for_query("info:fedora/#{id}")
      query = "#{DulHydra::IndexFields::IS_MEMBER_OF}:#{object_uri} OR #{DulHydra::IndexFields::IS_MEMBER_OF_COLLECTION}:#{object_uri} OR #{DulHydra::IndexFields::IS_PART_OF}:#{object_uri}"
      @children ||= ActiveFedora::SolrService.query(query)
    end
    
    def has_children?
      children.size > 0 ? true : false
    end
    
    def parsed_content_metadata
      JSON.parse(self[DulHydra::IndexFields::CONTENT_METADATA_PARSED].first)
    end

  end
end
