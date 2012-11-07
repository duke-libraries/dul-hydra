class Component < ActiveFedora::Base
  
  include Hydra::ModelMixins::CommonMetadata
  include Hydra::ModelMixins::RightsMetadata
  include Hydra::ModelMethods
  include DulHydra::ModelMixins::DescMetadata
  include DulHydra::ModelMixins::Content
  extend DulHydra::ModelMethods

  belongs_to :container, :property => :is_part_of, :class_name => 'Item'

  #has_file_datastream :name => "content", :type => ActiveFedora::Datastream

end
