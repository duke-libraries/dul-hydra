class Component < DulHydra::Base
 
  include DulHydra::HasContent

  belongs_to :parent, :property => :is_part_of, :class_name => 'Item'
  belongs_to :target, :property => :has_external_target, :class_name => 'Target'

  alias_method :item, :parent
  alias_method :item=, :parent=

  def collection
    self.parent.parent rescue nil
  end

end
