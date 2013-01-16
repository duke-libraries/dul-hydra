class PreservationEvent < ActiveFedora::Base
    
  include DulHydra::Models::Governable
  include DulHydra::Models::AccessControllable
  
  has_metadata :name => "eventMetadata", :type => DulHydra::Datastreams::PremisEventDatastream
  belongs_to :for_object, :property => :fixity_check
  delegate :id_type, :to => "eventMetadata", :at => [:identifier, :type], :unique => true
  delegate :id_value, :to => "eventMetadata", :at => [:identifier, :value], :unique => true
  delegate :outcome, :to => "eventMetadata", :at => [:outcome_information, :outcome]
  delegate :outcome_detail_note, :to => "eventMetadata", :at => [:outcome_information, :detail, :note]
  delegate :linking_obj_id_type, :to => "eventMetadata", :at => [:linking_object_id, :type]
  delegate :linking_obj_id_value, :to => "eventMetadata", :at => [:linking_object_id, :value]
  delegate_to :eventMetadata, [:datetime, :detail, :type], :unique => true
  
end

