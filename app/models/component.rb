class Component < DulHydra::Models::Base
 
  include DulHydra::Models::HasContent
  include DulHydra::Models::HasDigitizationGuide
  include DulHydra::Models::HasDPCMetadata
  include DulHydra::Models::HasFMPExport
  include DulHydra::Models::HasJhove

  belongs_to :container, :property => :is_part_of, :class_name => 'Item'

  alias_method :item, :container
  alias_method :item=, :container=

  alias_method :parent, :container
  alias_method :parent=, :container=

end
