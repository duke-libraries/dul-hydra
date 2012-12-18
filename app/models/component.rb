class Component < DulHydra::Models::Base
 
  include DulHydra::Models::HasContent
  include DulHydra::Models::HasDigitizationGuide

  belongs_to :container, :property => :is_part_of, :class_name => 'Item'

end
