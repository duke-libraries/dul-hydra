require 'json'

module DulHydra
  class FixityCheck

    attr_reader :object, :options, :datastream_ids

    LABEL = "Internal repository validation of datastream checksums"

    # Options are :only and :except.
    # Both take an Array with one or more datastream IDs
    # Array operations should prevent invalid datastream ID issues.
    def initialize(obj, options={})
      @object = obj
      @options = options
      @datastream_ids = @object.datastreams.keys
      @datastream_ids &= options[:only] if options[:only]
      @datastream_ids -= options.fetch(:except, [])
    end

    def execute
      outcome = PreservationEvent::SUCCESS
      detail = {
        datastreams: [], 
        options: options, 
        version: DulHydra::VERSION
      }
      datastream_ids.each do |dsid|
        ds = object.datastreams[dsid]
        outcome = PreservationEvent::FAILURE unless ds.dsChecksumValid
        detail[:datastreams] << ds.profile
      end
      PreservationEvent.new(:label => LABEL,
                            :event_type => PreservationEvent::FIXITY_CHECK,
                            :event_date_time => PreservationEvent.to_event_date_time,
                            :event_outcome => outcome,
                            :event_detail => detail.to_json,
                            :linking_object_id_type => PreservationEvent::OBJECT,
                            :linking_object_id_value => object.internal_uri,
                            :for_object => object
                            )
    end

    def execute!
      pe = execute
      pe.save!
      pe
    end

  end
end
