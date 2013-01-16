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

    DS_DATE_TIME_FORMAT = "%Y-%m-%dT%H:%M:%S.%LZ"

    PREMIS_NS = {"premis" => "info:lc/xmlns/premis-v2"}

    included do
      has_metadata :name => "preservationMetadata", :type => DulHydra::Datastreams::PreservationMetadataDatastream, :label => "Preservation metadata", :versionable => true, :control_group => 'M'
    end

    def check_fixity
      events = []
      self.reload # ensure that AF object datastreams are in sync with Fedora
      self.datastreams.each do |dsID, ds|
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
      num_events = self.preservationMetadata.event.length
      events.each_with_index do |event, i|
        n = num_events + i
        self.preservationMetadata.event(n).linking_object_id.type = "datastream"
        self.preservationMetadata.event(n).linking_object_id.value = event[:dsID] + "?asOfDateTime=" + event[:dsProfile]["dsCreateDate"].strftime(DS_DATE_TIME_FORMAT)
        self.preservationMetadata.event(n).type = EVENT_TYPE_FIXITY_CHECK
        self.preservationMetadata.event(n).detail = "Datastream version checksum validation"
        self.preservationMetadata.event(n).identifier.type = EVENT_IDENTIFIER_TYPE_UUID
        self.preservationMetadata.event(n).identifier.value = SecureRandom.uuid
        self.preservationMetadata.event(n).datetime = event[:eventDateTime].strftime(EVENT_DATE_TIME_FORMAT)
        self.preservationMetadata.event(n).outcome_information.outcome = event[:eventOutcome]
      end
      self.save!
    end

  end
end
