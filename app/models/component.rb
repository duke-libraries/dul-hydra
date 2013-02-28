class Component < DulHydra::Models::Base
 
  include DulHydra::Models::HasContent
  include DulHydra::Models::HasDigitizationGuide
  include DulHydra::Models::HasDPCMetadata
  include DulHydra::Models::HasFMPExport
  include DulHydra::Models::HasJhove
  include DulHydra::Models::HasThumbnail

  belongs_to :container, :property => :is_part_of, :class_name => 'Item'
  belongs_to :target, :property => :has_external_target, :class_name => 'Target'

  alias_method :item, :container
  alias_method :item=, :container=

  alias_method :parent, :container
  alias_method :parent=, :container=

end
