class Attachment < DulHydra::Base

  include DulHydra::HasContent
  
  belongs_to :attached_to, property: :is_attached_to, class_name: 'ActiveFedora::Base'
  validates_presence_of :title, :content, :attached_to
  
end
