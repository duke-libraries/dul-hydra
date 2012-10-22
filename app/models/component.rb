class Component < ActiveFedora::Base
  
  include ActiveFedora::Relationships

  has_relationship "part_of", :is_part_of

  has_file_datastream :name => "content", :type => ActiveFedora::Datastream

end
