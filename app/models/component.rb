class Component < DulHydra::Models::Base
 
  include DulHydra::Models::HasContent
  include DulHydra::Models::HasDigitizationGuide
  include DulHydra::Models::HasDPCMetadata
  include DulHydra::Models::HasFMPExport
  include DulHydra::Models::HasThumbnail

  belongs_to :parent, :property => :is_part_of, :class_name => 'Item'
  belongs_to :target, :property => :has_external_target, :class_name => 'Target'

  alias_method :item, :parent
  alias_method :item=, :parent=

  alias_method :container, :parent
  alias_method :container=, :parent=

  def collection
    self.parent.parent rescue nil
  end

end
