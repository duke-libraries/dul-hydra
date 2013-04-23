require 'json'

module DulHydra
  class FixityCheck

    attr_reader :object, :options :datastream_ids, :check_detail
    attr_accessor :check_result, :check_date

    LABEL = "Internal repository validation of datastream checksums"

    # Options are :only and :except.
    # Both take an Array with one or more datastream IDs
    # Array operations should prevent invalid datastream ID issues.
    def initialize(object, options={})
      @object = object
      @datastream_ids = @object.datastreams.keys
      @datastream_ids &= options[:only] if options[:only]
      @datastream_ids -= options.fetch(:except, [])
      @check_detail = {}
    end

    def execute
      check_date = Time.now.utc
      datastream_ids.each do |dsid|
        ds = object.datastreams[dsid]
        check_result = false unless ds.dsChecksumValid
        check_detail[dsid] = ds.profile
      end
      check_result = true if check_result.nil?
      check_result
    end

    def to_preservation_event
      event_detail = {datastreams: check_detail, version: DulHydra::VERSION}
      PreservationEvent.new(:label => LABEL,
                            :event_type => PreservationEvent::FIXITY_CHECK,
                            :event_date_time => PreservationEvent.to_event_date_time(check_date),
                            :event_outcome => check_result ? PreservationEvent::SUCCESS : PreservationEvent::FAILURE,
                            :event_detail => event_detail.to_json,
                            :linking_object_id_type => PreservationEvent::OBJECT,
                            :linking_object_id_value => object.internal_uri,
                            :for_object => object
                            )      
    end

  end
end
