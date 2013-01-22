module DulHydra::Models
  module FixityCheckable
    extend ActiveSupport::Concern

    # include HasPreservationEvents
    
    def fixity_checks
      # XXX better to get from index?
      self.preservation_events.select { |e| e.fixity_check? }
    end

    def validate_ds_checksum(ds)
      pe = PreservationEvent.new(:label => "Datastream checksum validation")
      pe.event_date_time = Time.now.utc.strftime(PreservationEvent::DATE_TIME_FORMAT)
      pe.event_outcome = ds.profile(:validateChecksum => true)["dsChecksumValid"] ? "PASSED" : "FAILED"
      pe.linking_object_id_type = "datastream"
      pe.linking_object_id_value = "#{self.internal_uri}/datastreams/#{ds.dsid}?asOfDateTime=" + ds.dsCreateDate.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
      pe.event_type = PreservationEvent::FIXITY_CHECK
      pe.event_detail = "Datastream checksum validation"
      return pe
    end

    def validate_ds_checksum!(ds)
      pe = self.validate_ds_checksum(ds)
      pe.save!
      self.preservation_events << pe
      return pe
    end

  end
end
