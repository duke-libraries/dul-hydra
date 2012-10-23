class Component < ActiveFedora::Base
  
  #include ActiveFedora::Relationships
  include Hydra::ModelMethods

  #has_relationship "part_of", :is_part_of
  belongs_to :item, :property => :is_part_of, :class_name => 'Item'

  has_file_datastream :name => "content", :type => ActiveFedora::Datastream

end
