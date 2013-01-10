require 'json'
require 'securerandom'

module DulHydra::Models
  module HasPreservationMetadata
    extend ActiveSupport::Concern

    EVENT_IDENTIFIER_TYPE_UUID = "UUID"
    FIXITY_CHECK_EVENT_TYPE = "fixity check"
    FIXITY_CHECK_PASSED = "PASSED"
    FIXITY_CHECK_FAILED = "FAILED"
    FIXITY_CHECK_EVENT_DETAIL = "Datastream checksum validation. The event outcome \"#{FIXITY_CHECK_PASSED}\" indicates that all datastreams having checksums enabled were successfully validated; the outcome \"#{FIXITY_CHECK_FAILED}\" indicates that one or more datastreams failed checksum validation. The eventOutcomeDetail element contains the detailed validation results in JSON format."

    included do
      has_metadata :name => "preservationMetadata", :type => DulHydra::Datastreams::PreservationMetadataDatastream
    end

    def check_fixity
      event = {:datetime => now, :outcome => FIXITY_CHECK_PASSED, :detail => []}
      datastreams.each do |id, ds|
        next if ds.profile.empty? || ds.profile["dsChecksumType"] == "DISABLED"
        result = {:datastream_id => id, :datetime => now, :outcome => FIXITY_CHECK_PASSED}
        unless ds.dsChecksumValid
          result[:outcome] = FIXITY_CHECK_FAILED
          event[:outcome] = FIXITY_CHECK_FAILED
        end
        event[:detail] << result
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
      preservationMetadata.event(event_num).datetime = event[:datetime]
      preservationMetadata.event(event_num).outcome_information.outcome = event[:outcome]
      preservationMetadata.event(event_num).outcome_information.detail.note = event[:detail].to_json
      save!
    end

    private

    def now
      Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
    end

  end
end
