require 'json'
require 'securerandom'

module DulHydra::Models
  module HasPreservationMetadata
    extend ActiveSupport::Concern

    FIXITY_CHECK_PASSED = "PASSED"
    FIXITY_CHECK_FAILED = "FAILED"

    EVENT_IDENTIFIER_TYPE_UUID = "UUID"
    EVENT_DATE_TIME_FORMAT = "%Y-%m-%dT%H:%M:%S.%LZ"
    EVENT_TYPE_FIXITY_CHECK = "fixity check"

    included do
      has_metadata :name => "preservationMetadata", :type => DulHydra::Datastreams::PreservationMetadataDatastream, :label => "Preservation metadata", :versionable => true, :control_group => 'M'
    end

    def check_fixity
      events = []
      datastreams.each do |dsID, ds|
        # XXX filter out datastreams we don't want to check?
        ds.versions.each do |ds_version| 
          dsProfile = ds_version.profile(:validateChecksum => true)
          next if dsProfile.empty? || dsProfile["dsChecksumType"] == "DISABLED"
          events << {
            :dsID => dsID,
            :dsProfile => dsProfile,
            :eventDateTime => Time.now.utc,
            :eventOutcome => dsProfile["dsChecksumValid"] ? FIXITY_CHECK_PASSED : FIXITY_CHECK_FAILED,
          }          
        end
      end        
      return events
    end

    def check_fixity!
      events = self.check_fixity
      return if events.empty?
      num_events = preservationMetadata.event.length
      events.each_with_index do |event, i|
        preservationMetadata.event(num_events + i).linking_object_id.type = "info:fedora/#{self.pid}/datastreams/" + event[:dsID]
        preservationMetadata.event(num_events + i).linking_object_id.value = event[:dsProfile]["dsVersionID"]
        preservationMetadata.event(num_events + i).type = EVENT_TYPE_FIXITY_CHECK
        preservationMetadata.event(num_events + i).detail = "Datastream version checksum validation"
        preservationMetadata.event(num_events + i).identifier.type = EVENT_IDENTIFIER_TYPE_UUID
        preservationMetadata.event(num_events + i).identifier.value = SecureRandom.uuid
        preservationMetadata.event(num_events + i).datetime = event[:eventDateTime].strftime(EVENT_DATE_TIME_FORMAT)
        preservationMetadata.event(num_events + i).outcome_information.outcome = event[:eventOutcome]
      end
      save!
    end

  end
end
