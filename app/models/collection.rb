class Collection < DulHydra::Base
  
  include DulHydra::HasChildren
  include DulHydra::HasAttachments

  has_many :children, :property => :is_member_of_collection, :inbound => true, :class_name => 'Item'
  has_many :targets, :property => :is_external_target_for, :inbound => true, :class_name => 'Target'

  alias_method :items, :children
  alias_method :item_ids, :child_ids

  validates_presence_of :title

  def components_from_solr
    outer = DulHydra::IndexFields::IS_PART_OF
    inner = DulHydra::IndexFields::INTERNAL_URI
    where = ActiveFedora::SolrService.construct_query_for_rel(:is_member_of_collection => internal_uri)
    query = "{!join to=#{outer} from=#{inner}}#{where}"
    filter = ActiveFedora::SolrService.construct_query_for_rel(:has_model => Component.to_class_uri)
    results = ActiveFedora::SolrService.query(query, fq: filter, rows: 100000)
    results.lazy.map {|doc| SolrDocument.new(doc)}
  end

end
