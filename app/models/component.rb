class Component < ActiveFedora::Base
  
  include Hydra::ModelMixins::CommonMetadata
  include Hydra::ModelMixins::RightsMetadata
  include DulHydra::Models::Describable
  include DulHydra::Models::Content

  belongs_to :container, :property => :is_part_of, :class_name => 'Item'

end
