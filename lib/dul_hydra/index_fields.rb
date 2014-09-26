module DulHydra::IndexFields

  def self.solr_name(*args)
    ActiveFedora::SolrService.solr_name(*args)
  end
  
  ACTIVE_FEDORA_MODEL       = solr_name :active_fedora_model, :stored_sortable
  CONTENT_CONTROL_GROUP     = solr_name :content_control_group, :searchable, type: :string
  CONTENT_METADATA_PARSED   = solr_name :content_metadata_parsed, :symbol
  CONTENT_SIZE              = solr_name :content_size, :stored_sortable, type: :integer
  CONTENT_SIZE_HUMAN        = solr_name :content_size_human, :symbol
  CREATOR                   = solr_name :creator, :facetable
  HAS_MODEL                 = solr_name :has_model, :symbol
  IDENTIFIER                = solr_name :identifier, :stored_sortable
  INTERNAL_URI              = solr_name :internal_uri, :symbol
  IS_ATTACHED_TO            = solr_name :is_attached_to, :symbol
  IS_EXTERNAL_TARGET_FOR    = solr_name :is_external_target_for, :symbol
  IS_GOVERNED_BY            = solr_name :is_governed_by, :symbol
  IS_MEMBER_OF              = solr_name :is_member_of, :symbol
  IS_MEMBER_OF_COLLECTION   = solr_name :is_member_of_collection, :symbol
  IS_PART_OF                = solr_name :is_part_of, :symbol
  LAST_FIXITY_CHECK_ON      = solr_name :last_fixity_check_on, :stored_sortable, type: :date
  LAST_FIXITY_CHECK_OUTCOME = solr_name :last_fixity_check_outcome, :symbol
  LAST_VIRUS_CHECK_ON       = solr_name :last_virus_check_on, :stored_sortable, type: :date
  LAST_VIRUS_CHECK_OUTCOME  = solr_name :last_virus_check_outcome, :symbol
  MEDIA_SUB_TYPE            = solr_name :content_media_sub_type, :facetable
  MEDIA_MAJOR_TYPE          = solr_name :content_media_major_type, :facetable
  MEDIA_TYPE                = solr_name :content_media_type, :symbol
  METADATA_TYPE             = solr_name :metadata_type, :facetable
  OBJECT_PROFILE            = solr_name :object_profile, :displayable
  OBJECT_STATE              = solr_name :object_state, :stored_sortable
  OBJECT_CREATE_DATE        = solr_name :system_create, :stored_sortable, type: :date
  OBJECT_MODIFIED_DATE      = solr_name :system_modified, :stored_sortable, type: :date
  ORIGINAL_FILENAME         = solr_name :original_filename, :symbol
  PERMANENT_ID              = solr_name :permanent_id, :symbol
  SUBJECT                   = solr_name :subject, :facetable
  TITLE                     = solr_name :title, :stored_sortable

end
