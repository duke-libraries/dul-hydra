class AdminPolicy < DulHydra::Models::Base
  has_metadata :name => "defaultRights", :type => Hydra::Datastream::InheritableRightsMetadata 
end
