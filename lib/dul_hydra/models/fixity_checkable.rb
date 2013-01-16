module DulHydra::Models
  module FixityCheckable
    extend ActiveSupport::Concern
    
    def fixity_checks
      # XXX probably better to get data from search
      self.preservation_events.select { |e| e.type == PreservationEvent::FIXITY_CHECK }
    end

    def validate_ds_checksum(ds)
      pe = PreservationEvent.new(:label => "Datastream checksum validation")
      pe.datetime = Time.now.utc.strftime(PreservationEvent::DATE_TIME_FORMAT)
      dsProfile = ds.profile(:validateChecksum => true)
      pe.outcome = dsProfile["dsChecksumValid"] ? "PASSED" : "FAILED"
      pe.linking_obj_id_type = "datastream"
      pe.linking_obj_id_value = "info:fedora/#{ds.pid}/datastreams/#{ds.dsid}?asOfDateTime=" + ds.profile["dsCreateDate"].strftime("%Y-%m-%dT%H:%M:%S.%LZ")
      pe.type = PreservationEvent::FIXITY_CHECK
      pe.detail = "Datastream checksum validation"
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
