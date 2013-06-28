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
      object_profile["objState"]
    end

    def object_create_date
      parse_date(object_profile["objCreateDate"])
    end

    def object_modified_date
      parse_date(object_profile["objLastModDate"])
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

    # Field name for parent PID on the child index document
    def parent_index_field
      case
      when active_fedora_model == "Component"
        DulHydra::IndexFields::IS_PART_OF
      when active_fedora_model == "Item"
        DulHydra::IndexFields::IS_MEMBER_OF_COLLECTION
      end
    end

    def label
      object_profile["objLabel"]
    end

    def title
      get(DulHydra::IndexFields::TITLE) || label || "#{active_fedora_model} #{id}"
    end

    def identifier
      # We want the multivalued version here
      get(ActiveFedora::SolrService.solr_name(:identifier, :stored_searchable, type: :text))
    end
    
    def has_thumbnail?
      has_datastream?(DulHydra::Datastreams::THUMBNAIL)
    end

    def has_content?
      has_datastream?(DulHydra::Datastreams::CONTENT)
    end

    def content_ds
      datastreams[DulHydra::Datastreams::CONTENT]
    end

    def content_mime_type
      content_ds["dsMIME"] rescue nil
    end

    def content_size
      content_ds["dsSize"] rescue nil
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
    
    def parsed_content_metadata
      JSON.parse(self[DulHydra::IndexFields::CONTENT_METADATA_PARSED].first)
    end

    private

    def targets_query
      "#{DulHydra::IndexFields::IS_EXTERNAL_TARGET_FOR}:#{internal_uri_for_query}"
    end

    def internal_uri_for_query
      ActiveFedora::SolrService.escape_uri_for_query(internal_uri)
    end

    def get_date(field)
      parse_date(get(field))
    end

    def parse_date(date)
      Time.parse(date).localtime if date
    end

  end
end
