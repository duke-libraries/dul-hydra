require 'json'

module DulHydra::Models
  module FixityCheckable
    extend ActiveSupport::Concern

    FIXITY_CHECK_PASSED = "PASSED"
    FIXITY_CHECK_FAILED = "FAILED"
    CHECKSUM_VALID = "VALID"
    CHECKSUM_INVALID = "INVALID"
    CHECKSUM_DISABLED = "DISABLED"

    included do
      has_metadata :name => "fixityCheck", :type => DulHydra::Datastreams::FixityCheckDatastream
      # delegate :fixity_check_date, :to => "fixityCheck", :at => [:date_time], :unique => true
      # delegate :fixity_check_outcome, :to => "fixityCheck", :at => [:outcome], :unique => true
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
      fixityCheck.datetime = results[:datetime]
      fixityCheck.outcome = results[:outcome]
      fixityCheck.outcome_detail = results[:outcome_detail].to_json
      save!
    end

    private

    def now
      Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
    end

  end
end
