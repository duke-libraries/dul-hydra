class Item < DulHydra::Models::Base
  
  include DulHydra::Models::HasContentdm
  include DulHydra::Models::HasMarcXML
  include DulHydra::Models::HasContentMetadata
  include DulHydra::Models::HasTripodMets

  has_many :children, :property => :is_part_of, :inbound => true, :class_name => 'Component'
  belongs_to :parent, :property => :is_member_of_collection, :class_name => 'Collection'

  alias_method :components, :children
  alias_method :component_ids, :child_ids

  alias_method :parts, :children
  alias_method :part_ids, :child_ids

  alias_method :collection, :parent
  alias_method :collection_id, :parent_id
  alias_method :collection=, :parent=
    
end
