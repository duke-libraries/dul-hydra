class Item < ActiveFedora::Base

  include ActiveFedora::Relationships

  has_relationship "member_of", :is_member_of
  has_relationship "parts", :is_part_of, :inbound => true
  
end
