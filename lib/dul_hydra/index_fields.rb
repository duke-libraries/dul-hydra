module DulHydra::IndexFields
  
  ACTIVE_FEDORA_MODEL = ActiveFedora::SolrService.solr_name(:active_fedora_model, :symbol)
  CONTENT_METADATA_PARSED = ActiveFedora::SolrService.solr_name(:content_metadata_parsed, :symbol)
  IDENTIFIER = ActiveFedora::SolrService.solr_name(:identifier, :stored_searchable, type: :text)
  IS_EXTERNAL_TARGET_FOR = ActiveFedora::SolrService.solr_name(:is_external_target_for, :symbol)
  IS_GOVERNED_BY = ActiveFedora::SolrService.solr_name(:is_governed_by, :symbol)
  IS_MEMBER_OF = ActiveFedora::SolrService.solr_name(:is_member_of, :symbol)
  IS_MEMBER_OF_COLLECTION = ActiveFedora::SolrService.solr_name(:is_member_of_collection, :symbol)
  IS_PART_OF = ActiveFedora::SolrService.solr_name(:is_part_of, :symbol)
  IS_PRESERVATION_EVENT_FOR = ActiveFedora::SolrService.solr_name(:is_preservation_event_for, :symbol)
  TITLE = ActiveFedora::SolrService.solr_name(:title, :stored_sortable)
  
  

end