class Ancillary < DulHydra::Models::Base

  include DulHydra::Models::HasContent
  
  belongs_to :collection, :property => :is_ancillary_for_collection, :class_name => 'Collection'
  
  belongs_to :item, :property => :is_ancillary_for_item, :class_name => 'Item'
  
  belongs_to :component, :property => :is_ancillary_for_component, :class_name => 'Component'
  
  def ancillary_for
    collection || item || component
  end
  
  def ancillary_for=(object)
    case object.class.name
    when "Collection"
      self.collection = object
    when "Item"
      self.item = object
    when "Component"
      self.component = object
    else
      raise ArgumentError, "#{object.class} not supported as target of ancillary relationship"
    end
  end
  
end