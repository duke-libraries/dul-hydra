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
      datastreams.each do |dsID, ds|
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
        preservationMetadata.event(num_events + i).linking_object_id.type = "datastreams/#{event[:dsID]}"
        preservationMetadata.event(num_events + i).linking_object_id.value = event[:dsProfile]["dsCreateDate"].strftime(DS_DATE_TIME_FORMAT)
        preservationMetadata.event(num_events + i).type = EVENT_TYPE_FIXITY_CHECK
        preservationMetadata.event(num_events + i).detail = "Datastream version checksum validation"
        preservationMetadata.event(num_events + i).identifier.type = EVENT_IDENTIFIER_TYPE_UUID
        preservationMetadata.event(num_events + i).identifier.value = SecureRandom.uuid
        preservationMetadata.event(num_events + i).datetime = event[:eventDateTime].strftime(EVENT_DATE_TIME_FORMAT)
        preservationMetadata.event(num_events + i).outcome_information.outcome = event[:eventOutcome]
      end
      save!
    end

    def fixity_checks
      fc = []
      preservationMetadata.fixity_check.each_index do |i|
        fc << {
          :datastream => preservationMetadata.fixity_check(i).linking_object_id.type.first,
          :dsCreateDate => preservationMetadata.fixity_check(i).linking_object_id.value.first,
          :eventDateTime => preservationMetadata.fixity_check(i).datetime.first,
          :eventOutcome => preservationMetadata.fixity_check(i).outcome
        }
      end
    end

    def datastream_fixity_checks(ds)
      ds_fixity_checks = []
      linking_object_id_type = "datastreams/#{ds.dsid}"
      linking_object_id_value = ds.profile["dsCreateDate"].strftime(DS_DATE_TIME_FORMAT)
      preservationMetadata.find_by_terms("//oxns:event[oxns:eventType = \"#{EVENT_TYPE_FIXITY_CHECK}\" and oxns:linkingObjectIdentifier/oxns:linkingObjectIdentifierType = \"#{linking_object_id_type}\" and oxns:linkingObjectIdentifier/oxns:linkingObjectIdentifierValue = \"#{linking_object_id_value}\"]").each do |node|
        ds_fixity_checks << {
          :eventDateTime => node.at_xpath(".//premis:eventDateTime", PREMIS_NS).text,
          :eventOutcome => node.at_xpath(".//premis:eventOutcome", PREMIS_NS).text
        }
      end
      ds_fixity_checks
    end

  end
end
