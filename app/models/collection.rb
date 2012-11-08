class Collection < ActiveFedora::Base

  include Hydra::ModelMixins::CommonMetadata
  include Hydra::ModelMixins::RightsMetadata
  include DulHydra::Models::Describable
  
  has_many :items, :property => :is_member_of, :inbound => true, :class_name => 'Item'
  
end
