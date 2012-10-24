class Collection < ActiveFedora::Base
  
  has_many :items, :property => :is_member_of, :inbound => true
  
  has_metadata :name => 'descMetadata', :type => ModsContent
  
  delegate_to 'descMetadata', [:identifier]
  delegate :title, :to => 'descMetadata', :at => [:title_info, :main_title]
  
end
