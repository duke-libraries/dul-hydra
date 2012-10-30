class Component < ActiveFedora::Base
  
  include Hydra::ModelMethods

  belongs_to :item, :property => :is_part_of, :class_name => 'Item'

  has_file_datastream :name => "content", :type => ActiveFedora::Datastream

  has_metadata :name => "descMetadata", :type => ModsContent
  delegate :title, :to => 'descMetadata', :at => [:title_info, :main_title]

end
