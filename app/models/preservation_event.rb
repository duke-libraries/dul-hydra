class PreservationEvent < ActiveFedora::Base
    
  include DulHydra::Models::Governable
  include DulHydra::Models::AccessControllable

  DATE_TIME_FORMAT = "%Y-%m-%dT%H:%M:%S.%LZ"
  FIXITY_CHECK = "fixity check" # http://id.loc.gov/vocabulary/preservationEvents/fixityCheck
  
  has_metadata :name => "eventMetadata", :type => DulHydra::Datastreams::PremisEventDatastream, :versionable => false, :label => "PREMIS event metadata"

  belongs_to :for_object, :property => :is_preservation_event_for

  delegate :id_type, :to => "eventMetadata", :at => [:identifier, :type], :unique => true
  delegate :id_value, :to => "eventMetadata", :at => [:identifier, :value], :unique => true
  delegate :outcome, :to => "eventMetadata", :at => [:outcome_information, :outcome], :unique => true
  delegate :outcome_detail_note, :to => "eventMetadata", :at => [:outcome_information, :detail, :note]
  delegate :linking_obj_id_type, :to => "eventMetadata", :at => [:linking_object_id, :type], :unique => true
  delegate :linking_obj_id_value, :to => "eventMetadata", :at => [:linking_object_id, :value], :unique => true
  delegate_to :eventMetadata, [:datetime, :detail, :type], :unique => true
  
end

