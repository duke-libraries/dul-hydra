require 'json'
require 'securerandom'

module DulHydra::Models
  module HasPreservationMetadata
    extend ActiveSupport::Concern

    EVENT_IDENTIFIER_TYPE_UUID = "UUID"
    FIXITY_CHECK_EVENT_TYPE = "fixity check"
    FIXITY_CHECK_PASSED = "PASSED"
    FIXITY_CHECK_FAILED = "FAILED"
    CHECKSUM_VALID = "VALID"
    CHECKSUM_INVALID = "INVALID"
    CHECKSUM_DISABLED = "DISABLED"

    included do
      has_metadata :name => "preservationMetadata", :type => DulHydra::Datastreams::PreservationMetadataDatastream
    end

    def check_fixity
      # XXX reload object from Fedora
      passed = true
      results = {:datetime => now, :outcome_detail => []}
      datastreams.reject { |id, ds| ds.profile.empty? }.each do |id, ds|
        result = {:datastream_id => id, :datetime => now}
        if ds.profile["dsChecksumType"] == "DISABLED"
          result[:checksum] = CHECKSUM_DISABLED
        elsif ds.dsChecksumValid
          result[:checksum] = CHECKSUM_VALID
        else
          result[:checksum] = CHECKSUM_INVALID
          passed = false
        end
        results[:outcome_detail] << result
      end        
      results[:outcome] = passed ? FIXITY_CHECK_PASSED : FIXITY_CHECK_FAILED
      return results
    end

    def check_fixity!
      results = check_fixity
      event_num = preservationMetadata.event.length
      preservationMetadata.event(event_num).type = FIXITY_CHECK_EVENT_TYPE
      preservationMetadata.event(event_num).identifier.type = EVENT_IDENTIFIER_TYPE_UUID
      preservationMetadata.event(event_num).identifier.value = SecureRandom.uuid
      preservationMetadata.event(event_num).datetime = results[:datetime]
      preservationMetadata.event(event_num).outcome_information.outcome = results[:outcome]
      preservationMetadata.event(event_num).outcome_information.detail.note = results[:outcome_detail].to_json
      save!
    end

    private

    def now
      Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
    end

  end
end
