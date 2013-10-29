class Collection < DulHydra::Models::Base
  
  include DulHydra::Models::HasChildren

  has_many :children, :property => :is_member_of_collection, :inbound => true, :class_name => 'Item'
  has_many :targets, :property => :is_external_target_for, :inbound => true, :class_name => 'Target'

  alias_method :items, :children
  alias_method :item_ids, :child_ids

  def components_query
    {
      q: "{!join to=#{DulHydra::IndexFields::IS_PART_OF} from=#{DulHydra::IndexFields::INTERNAL_URI}}#{ActiveFedora::SolrService.construct_query_for_rel(:is_member_of_collection => internal_uri)}",
      fq: ActiveFedora::SolrService.construct_query_for_rel(:has_model => Component.to_class_uri),
      rows: 10000
    }
  end
  
end
