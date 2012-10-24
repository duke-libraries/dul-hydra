class Component < ActiveFedora::Base
  
  include Hydra::ModelMethods

  belongs_to :item, :property => :is_part_of, :class_name => 'Item'

  has_file_datastream :name => "content", :type => ActiveFedora::Datastream

end
