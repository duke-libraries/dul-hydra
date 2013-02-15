class Target < DulHydra::Models::Base

  include DulHydra::Models::HasContent
  include DulHydra::Models::HasJhove

  has_many :components, :property => :is_external_target_for, :inbound => true, :class_name => 'Component'
  
end
