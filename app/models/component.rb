class Component < ActiveFedora::Base
  
  include Hydra::ModelMixins::CommonMetadata
  include Hydra::ModelMixins::RightsMetadata
  include Hydra::ModelMethods
  include DulHydra::ModelMixins::DescMetadata

  belongs_to :item, :property => :is_part_of, :class_name => 'Item'

  has_file_datastream :name => "content", :type => ActiveFedora::Datastream

  #has_metadata :name => "descMetadata", :type => ModsContent
  #delegate_to 'descMetadata', [:identifier]
  #delegate :title, :to => 'descMetadata', :at => [:title_info, :main_title]

end
