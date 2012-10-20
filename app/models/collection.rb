class Collection < ActiveFedora::Base
  
  include ActiveFedora::Relationships

  has_relationship "members", :is_member_of, :inbound => true

end
