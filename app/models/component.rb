class Component < DulHydra::Models::Base
 
  include DulHydra::Models::Contentable

  belongs_to :container, :property => :is_part_of, :class_name => 'Item'

end
