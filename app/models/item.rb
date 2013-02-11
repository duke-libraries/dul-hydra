class Item < DulHydra::Models::Base
  
  include DulHydra::Models::HasContentdm
  include DulHydra::Models::HasMarcXML
  include DulHydra::Models::HasContentMetadata
  include DulHydra::Models::HasTripodMets

  has_many :parts, :property => :is_part_of, :inbound => true, :class_name => 'Component'
  belongs_to :collection, :property => :is_member_of, :class_name => 'Collection'

  alias_method :components, :parts
  alias_method :children, :parts

  alias_method :parent, :collection
  alias_method :parent=, :collection=
    
end
