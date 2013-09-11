class Component < DulHydra::Models::Base
 
  include DulHydra::Models::HasContent
  include DulHydra::Models::HasDigitizationGuide
  include DulHydra::Models::HasDPCMetadata
  include DulHydra::Models::HasFMPExport

  belongs_to :parent, :property => :is_part_of, :class_name => 'Item'
  belongs_to :target, :property => :has_external_target, :class_name => 'Target'
  has_many :ancillaries, :property => :is_ancillary_for_component, :inbound => true, :class_name => 'Ancillary'

  alias_method :item, :parent
  alias_method :item=, :parent=

  alias_method :container, :parent
  alias_method :container=, :parent=

  def collection
    self.parent.parent rescue nil
  end

end
