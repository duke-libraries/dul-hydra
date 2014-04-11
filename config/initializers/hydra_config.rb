Hydra.configure do |config|
  # indexer = Solrizer::Descriptor.new(:string, :stored, :indexed, :multivalued)
  # config[:permissions] = {
  #   :discover => {:group =>ActiveFedora::SolrService.solr_name("discover_access_group", indexer), :individual=>ActiveFedora::SolrService.solr_name("discover_access_person", indexer)},
  #   :read => {:group =>ActiveFedora::SolrService.solr_name("read_access_group", indexer), :individual=>ActiveFedora::SolrService.solr_name("read_access_person", indexer)},
  #   :edit => {:group =>ActiveFedora::SolrService.solr_name("edit_access_group", indexer), :individual=>ActiveFedora::SolrService.solr_name("edit_access_person", indexer)},
  #   :owner => ActiveFedora::SolrService.solr_name("depositor", indexer),
  #   :embargo_release_date => ActiveFedora::SolrService.solr_name("embargo_release_date", Solrizer::Descriptor.new(:date, :stored, :indexed))
  # }
  # config[:permissions][:inheritable] = {
  #   :discover => {:group =>ActiveFedora::SolrService.solr_name("inheritable_discover_access_group", indexer), :individual=>ActiveFedora::SolrService.solr_name("inheritable_discover_access_person", indexer)},
  #   :read => {:group =>ActiveFedora::SolrService.solr_name("inheritable_read_access_group", indexer), :individual=>ActiveFedora::SolrService.solr_name("inheritable_read_access_person", indexer)},
  #   :edit => {:group =>ActiveFedora::SolrService.solr_name("inheritable_edit_access_group", indexer), :individual=>ActiveFedora::SolrService.solr_name("inheritable_edit_access_person", indexer)},
  #   :owner => ActiveFedora::SolrService.solr_name("inheritable_depositor", indexer),
  #   :embargo_release_date => ActiveFedora::SolrService.solr_name("inheritable_embargo_release_date", Solrizer::Descriptor.new(:date, :stored, :indexed))
  # }
  config.permissions.policy_class = AdminPolicy
end
