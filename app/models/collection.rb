class Collection < DulHydra::Models::Base
  
  has_many :items, :property => :is_member_of, :inbound => true, :class_name => 'Item'
  
end
