class Collection < DulHydra::Models::Base
  
  include DulHydra::Models::HasContentdm
  include DulHydra::Models::HasDigitizationGuide
  include DulHydra::Models::HasDPCMetadata
  include DulHydra::Models::HasFMPExport
  include DulHydra::Models::HasMarcXML
  include DulHydra::Models::HasTripodMets

  has_many :items, :property => :is_member_of, :inbound => true, :class_name => 'Item'
  has_many :targets, :property => :is_external_target_for, :inbound => true, :class_name => 'Target'

  alias_method :children, :items
  
end
