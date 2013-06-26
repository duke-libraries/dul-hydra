require 'json'

module DulHydra::Models
  module SolrDocument

    def active_fedora_model
      get(DulHydra::IndexFields::ACTIVE_FEDORA_MODEL)
    end

    def internal_uri
      get(DulHydra::IndexFields::INTERNAL_URI)
    end
    
    def object_profile
      @object_profile ||= JSON.parse(self[DulHydra::IndexFields::OBJECT_PROFILE].first)
    end

    def object_state
      get(DulHydra::IndexFields::OBJECT_STATE)
    end

    def object_create_date
      get_date(DulHydra::IndexFields::OBJECT_CREATE_DATE)
    end

    def object_modified_date
      get_date(DulHydra::IndexFields::OBJECT_MODIFIED_DATE)
    end

    def last_fixity_check_on
      get_date(DulHydra::IndexFields::LAST_FIXITY_CHECK_ON)
    end

    def last_fixity_check_outcome
      get(DulHydra::IndexFields::LAST_FIXITY_CHECK_OUTCOME)
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
      get(parent_index_field)
    end

    def parent_pid
      ActiveFedora::Base.pids_from_uris(parent_uri) if has_parent?
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
      @targets ||= ActiveFedora::SolrService.query(targets_query)
    end

    def targets_count
      @targets_count ||= ActiveFedora::SolrService.count(targets_query)
    end
    
    def has_target?
      targets_count > 0
    end
    
    def children
      @children ||= ActiveFedora::SolrService.query(children_query)
    end

    def children_count
      @children_count ||= ActiveFedora::SolrService.count(children_query)
    end
    
    def has_children?
      children_count > 0
    end

    def parsed_content_metadata
      JSON.parse(self[DulHydra::IndexFields::CONTENT_METADATA_PARSED].first)
    end

    private

    def targets_query
      "#{DulHydra::IndexFields::IS_EXTERNAL_TARGET_FOR}:#{internal_uri_for_query}"
    end

    def children_query
      "#{parent_index_field}:#{internal_uri_for_query}"
    end

    # Field name for parent PID on the child index document
    def parent_index_field
      case
      when active_fedora_model == "Component"
        DulHydra::IndexFields::IS_PART_OF
      when active_fedora_model == "Item"
        DulHydra::IndexFields::IS_MEMBER_OF_COLLECTION
      end
    end

    def internal_uri_for_query
      ActiveFedora::SolrService.escape_uri_for_query(internal_uri)
    end

    def get_date(field)
      Time.parse(get(field)).localtime rescue nil      
    end

  end
end
