require 'date'

module DulHydra::Models
  module FixityCheckable
    extend ActiveSupport::Concern

    CHECK_PASSED = "PASSED"
    CHECK_FAILED = "FAILED"

    included do
      has_metadata :name => "fixityCheck", :type => DulHydra::Datastreams::FixityCheckDatastream
    end

    def check_fixity
      results = { passed: [], failed: [], empty: [], disabled: [] }
      datastreams.each do |id, ds| 
        if ds.profile.empty?
          results[:empty] << id
        elsif ds.profile["dsChecksumType"] == "DISABLED"
          results[:disabled] << id
        elsif ds.dsChecksumValid
          results[:passed] << id
        else
          results[:failed] << id
        end
      end
      results[:date_time] = DateTime.now.to_s
      return results
    end

    def check_fixity!
      results = check_fixity
      fixityCheck.date_time = results[:date_time]
      fixityCheck.outcome = results[:failed].empty? ? CHECK_PASSED : CHECK_FAILED
      fixityCheck.outcome_detail = "PASSED: #{results[:passed].join(", ")}" +
        "\nFAILED: #{results[:failed].join(", ")}" +
        "\nDISABLED: #{results[:disabled].join(", ")}"
      save!
    end

  end
end
