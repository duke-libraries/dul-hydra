class Collection < ActiveFedora::Base
  
  include ActiveFedora::Relationships
  include Hydra::Datastream

  has_relationship "members", :is_member_of, :inbound => true
  
  has_metadata :name => 'descMetadata', :type => ModsGenericContent
  
  delegate_to 'descMetadata', [:abstract]
  delegate :title, :to => 'descMetadata', :at => [:title_info, :main_title]
  
end
