class PreservationEvent < ActiveFedora::Base
    
  include DulHydra::Models::Governable
  include DulHydra::Models::AccessControllable

  DATE_TIME_FORMAT = "%Y-%m-%dT%H:%M:%S.%LZ"
  FIXITY_CHECK = "fixity check" # http://id.loc.gov/vocabulary/preservationEvents/fixityCheck
  
  has_metadata :name => "eventMetadata", :type => DulHydra::Datastreams::PremisEventDatastream, 
               :versionable => false, :label => "PREMIS event metadata"

  belongs_to :for_object, :property => :is_preservation_event_for

  delegate_to :eventMetadata, [:event_date_time, :event_detail, :event_type, :event_id_type,
                               :event_id_value, :event_outcome, :event_outcome_detail_note,
                               :linking_object_id_type, :linking_object_id_value
                              ], :unique => true

  def fixity_check?
    self.event_type == FIXITY_CHECK
  end

end

