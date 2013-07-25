class Collection < DulHydra::Models::Base
  
  include DulHydra::Models::HasContentdm
  include DulHydra::Models::HasDigitizationGuide
  include DulHydra::Models::HasDPCMetadata
  include DulHydra::Models::HasFMPExport
  include DulHydra::Models::HasMarcXML
  include DulHydra::Models::HasTripodMets
  include DulHydra::Models::HasChildren

  has_many :children, :property => :is_member_of_collection, :inbound => true, :class_name => 'Item'
  has_many :targets, :property => :is_external_target_for, :inbound => true, :class_name => 'Target'

  alias_method :items, :children
  alias_method :item_ids, :child_ids

  def components_query
    "{!join to=#{DulHydra::IndexFields::IS_PART_OF} from=#{DulHydra::IndexFields::INTERNAL_URI}}#{DulHydra::IndexFields::IS_MEMBER_OF_COLLECTION}:\"#{internal_uri}\""
  end
  
end
