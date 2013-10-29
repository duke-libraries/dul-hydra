class Attachment < DulHydra::Models::Base

  include DulHydra::Models::HasContent
  
  belongs_to :attached_to, 
             :property => :is_attached_to, 
             :class_name => 'ActiveFedora::Base'
  
end
