class Collection < DulHydra::Models::Base
  
  include DulHydra::Models::HasContentdm
  include DulHydra::Models::HasDigitizationGuide
  include DulHydra::Models::HasDPCMetadata
  include DulHydra::Models::HasFMPExport
  include DulHydra::Models::HasMarcXML

  has_many :items, :property => :is_member_of, :inbound => true, :class_name => 'Item'
  
end
