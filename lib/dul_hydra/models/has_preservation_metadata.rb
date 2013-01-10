require 'json'
require 'securerandom'

module DulHydra::Models
  module HasPreservationMetadata
    extend ActiveSupport::Concern

    STRFTIME_FORMAT = "%Y-%m-%dT%H:%M:%S.%LZ"
    EVENT_IDENTIFIER_TYPE_UUID = "UUID"
    FIXITY_CHECK_EVENT_TYPE = "fixity check"
    FIXITY_CHECK_PASSED = "PASSED"
    FIXITY_CHECK_FAILED = "FAILED"
    FIXITY_CHECK_EVENT_DETAIL = "Datastream checksum validation. The event outcome \"#{FIXITY_CHECK_PASSED}\" indicates that all versions of all datastreams having checksums enabled were successfully validated; the outcome \"#{FIXITY_CHECK_FAILED}\" indicates that one or more datastream versions failed checksum validation. The eventOutcomeDetail element contains the detailed validation results in JSON format."

    included do
      has_metadata :name => "preservationMetadata", :type => DulHydra::Datastreams::PreservationMetadataDatastream
    end

    def check_fixity
      event = {:eventDateTime => Time.now.utc, :eventOutcome => FIXITY_CHECK_PASSED, :eventOutcomeDetail => []}
      datastreams.each do |dsID, ds|
        next if ds.profile.empty?
        ds.versions.each do |ds_version| 
          event[:eventOutcomeDetail] << {
            :dsID => dsID,
            :dsVersionID => ds_version.profile["dsVersionID"],
            :dsChecksumType => ds_version.profile["dsChecksumType"],
            :dsCreateDate => ds_version.profile["dsCreateDate"],
            :eventDateTime => Time.now.utc,
            :dsChecksumValid => ds_version.dsChecksumValid
          }
        end
        event[:eventOutcomeDetail].each do |e|
          next if e[:dsChecksumValid]
          event[:eventOutcome] = FIXITY_CHECK_FAILED
          break
        end
      end        
      return event
    end

    def check_fixity!
      event = self.check_fixity
      event_num = preservationMetadata.event.length
      preservationMetadata.event(event_num).type = FIXITY_CHECK_EVENT_TYPE
      preservationMetadata.event(event_num).detail = FIXITY_CHECK_EVENT_DETAIL
      preservationMetadata.event(event_num).identifier.type = EVENT_IDENTIFIER_TYPE_UUID
      preservationMetadata.event(event_num).identifier.value = SecureRandom.uuid
      preservationMetadata.event(event_num).datetime = event[:eventDateTime].strftime(STRFTIME_FORMAT)
      preservationMetadata.event(event_num).outcome_information.outcome = event[:eventOutcome]
      preservationMetadata.event(event_num).outcome_information.detail.note = event[:eventOutcomeDetail].to_json
      save!
    end

  end
end
