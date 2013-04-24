module DulHydra::IndexFields
  
  ACTIVE_FEDORA_MODEL = ActiveFedora::SolrService.solr_name(:active_fedora_model, :symbol)
  CONTENT_METADATA_PARSED = ActiveFedora::SolrService.solr_name(:content_metadata_parsed, :symbol)
  EVENT_DATE_TIME = ActiveFedora::SolrService.solr_name(:event_date_time, :sortable, type: :date)
  EVENT_OUTCOME = ActiveFedora::SolrService.solr_name(:event_outcome, :symbol)
  EVENT_OUTCOME_DETAIL_NOTE = ActiveFedora::SolrService.solr_name(:event_outcome_detail_note, :displayable)
  EVENT_ID_TYPE = ActiveFedora::SolrService.solr_name(:event_id_type, :symbol)
  EVENT_ID_VALUE = ActiveFedora::SolrService.solr_name(:event_id_value, :symbol)
  EVENT_TYPE = ActiveFedora::SolrService.solr_name(:event_type, :symbol)
  IDENTIFIER = ActiveFedora::SolrService.solr_name(:identifier, :stored_searchable, type: :text)
  IS_EXTERNAL_TARGET_FOR = ActiveFedora::SolrService.solr_name(:is_external_target_for, :symbol)
  IS_GOVERNED_BY = ActiveFedora::SolrService.solr_name(:is_governed_by, :symbol)
  IS_MEMBER_OF = ActiveFedora::SolrService.solr_name(:is_member_of, :symbol)
  IS_MEMBER_OF_COLLECTION = ActiveFedora::SolrService.solr_name(:is_member_of_collection, :symbol)
  IS_PART_OF = ActiveFedora::SolrService.solr_name(:is_part_of, :symbol)
  IS_PRESERVATION_EVENT_FOR = ActiveFedora::SolrService.solr_name(:is_preservation_event_for, :symbol)
  LAST_FIXITY_CHECK_ON = ActiveFedora::SolrService.solr_name(:last_fixity_check_on, :sortable, type: :date)
  LAST_FIXITY_CHECK_OUTCOME = ActiveFedora::SolrService.solr_name(:last_fixity_check_outcome, :symbol)
  LINKING_OBJECT_ID_TYPE = ActiveFedora::SolrService.solr_name(:linking_object_id_type, :symbol)
  LINKING_OBJECT_ID_VALUE = ActiveFedora::SolrService.solr_name(:linking_object_id_value, :symbol)
  OBJECT_PROFILE = ActiveFedora::SolrService.solr_name(:object_profile, :displayable)
  TITLE = ActiveFedora::SolrService.solr_name(:title, :stored_sortable)

end
