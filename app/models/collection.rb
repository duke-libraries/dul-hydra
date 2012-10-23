class Collection < ActiveFedora::Base
  
  include Hydra::Datastream

  has_many :items, :property => :is_member_of, :inbound => true
  
  has_metadata :name => 'descMetadata', :type => ModsGenericContent
  
  delegate_to 'descMetadata', [:abstract]
  delegate :title, :to => 'descMetadata', :at => [:title_info, :main_title]
  
end
