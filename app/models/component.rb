class Component < ActiveFedora::Base
  
  include ActiveFedora::Relationships

  has_relationship "part_of", :is_part_of

end
