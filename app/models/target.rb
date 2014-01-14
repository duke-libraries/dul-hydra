class Target < DulHydra::Base

  include DulHydra::HasContent

  has_many :components, :property => :has_external_target, :inbound => true, :class_name => 'Component'
  belongs_to :collection, :property => :is_external_target_for, :class_name => 'Collection'
  
end
