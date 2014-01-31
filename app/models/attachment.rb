class Attachment < DulHydra::Base

  include DulHydra::HasContent
  
  belongs_to :attached_to, 
             :property => :is_attached_to, 
             :class_name => 'ActiveFedora::Base'

  validates :title, presence: true
  validates :content, has_content: true
  validates :attached_to, presence: true
  
end
