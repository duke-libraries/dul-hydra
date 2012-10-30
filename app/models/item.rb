class Item < ActiveFedora::Base

  include Hydra::ModelMixins::CommonMetadata
  include Hydra::ModelMixins::RightsMetadata

  has_many :components, :property => :is_part_of, :inbound => true, :class_name => 'Component'
  belongs_to :collection, :property => :is_member_of, :class_name => 'Collection'
  
  has_metadata :name => 'descMetadata', :type => ModsContent
  
  delegate_to 'descMetadata', [:identifier]
  delegate :title, :to => 'descMetadata', :at => [:title_info, :main_title]
  
end
