class Item < ActiveFedora::Base

  include Hydra::ModelMethods

  has_many :components, :property => :is_part_of, :inbound => true, :class_name => 'Component'
  belongs_to :collection, :property => :is_member_of, :class_name => 'Collection'
  
end
