require 'json'

module DulHydra::Models
  module SolrDocument

    def object_profile
      @object_profile ||= JSON.parse(self[ActiveFedora::SolrService.solr_name(:object_profile, :displayable)].first)
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
      get(ActiveFedora::SolrService.solr_name(:is_governed_by, :symbol))
    end

    def admin_policy_pid
      uri = admin_policy_uri
      uri &&= ActiveFedora::Base.pids_from_uris(uri)
    end

    def has_parent?
      !parent_uri.blank?
    end

    def parent_uri
      get(ActiveFedora::SolrService.solr_name(:is_part_of, :symbol)) || get(ActiveFedora::SolrService.solr_name(:is_member_of, :symbol)) || get(ActiveFedora::SolrService.solr_name(:is_member_of_collection, :symbol))
    end

    def parent_pid
      uri = parent_uri
      uri &&= ActiveFedora::Base.pids_from_uris(uri)
    end

    def active_fedora_model
      get(ActiveFedora::SolrService.solr_name(:active_fedora_model, :symbol))
    end
    
    def has_thumbnail?
      has_datastream?(DulHydra::Datastreams::THUMBNAIL)
    end

    def has_content?
      has_datastream?(DulHydra::Datastreams::CONTENT)
    end
    
    def targets
      object_uri = ActiveFedora::SolrService.escape_uri_for_query("info:fedora/#{id}")
      query = "#{ActiveFedora::SolrService.solr_name(:is_external_target_for, :symbol)}:#{object_uri}"
      @targets ||= ActiveFedora::SolrService.query(query)
    end
    
    def has_target?
      targets.size > 0 ? true : false
    end
    
    def children
      object_uri = ActiveFedora::SolrService.escape_uri_for_query("info:fedora/#{id}")
      query = "#{ActiveFedora::SolrService.solr_name(:is_member_of, :symbol)}:#{object_uri} OR #{ActiveFedora::SolrService.solr_name(:is_member_of_collection, :symbol)}:#{object_uri} OR #{ActiveFedora::SolrService.solr_name(:is_part_of, :symbol)}:#{object_uri}"
      @children ||= ActiveFedora::SolrService.query(query)
    end
    
    def has_children?
      children.size > 0 ? true : false
    end
    
    def parsed_content_metadata
      JSON.parse(self[ActiveFedora::SolrService.solr_name(:content_metadata_parsed, :symbol)].first)
    end

  end
end
