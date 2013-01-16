module DulHydra::Models
  module FixityCheckable
    extend ActiveSupport::Concern

    EVENT_OUTCOME_PASSED = "PASSED"
    EVENT_OUTCOME_FAILED = "FAILED"
    LINKING_OBJECT_ID_TYPE = "datastream"
    EVENT_DETAIL = "Datastream checksum validation"
    EVENT_TYPE = "fixity check" # http://id.loc.gov/vocabulary/preservationEvents/fixityCheck

    DATASTREAM_DATE_TIME_FORMAT = "%Y-%m-%dT%H:%M:%S.%LZ"
    EVENT_DATE_TIME_FORMAT = "%Y-%m-%dT%H:%M:%S.%LZ"

    included do
      has_many :fixity_checks, :property => :is_fixity_check_for, :inbound => true, :class_name => 'PreservationEvent'
    end
    
    def validate_ds_checksum(ds)
      pe = PreservationEvent.new(:label => EVENT_DETAIL)
      pe.datetime = Time.now.utc.strftime(EVENT_DATE_TIME_FORMAT)
      dsProfile = ds.profile(:validateChecksum => true)
      pe.outcome = dsProfile["dsChecksumValid"] ? EVENT_OUTCOME_PASSED : EVENT_OUTCOME_FAILED
      pe.linking_obj_id_type = LINKING_OBJECT_ID_TYPE
      pe.linking_obj_id_value = linking_object_id_value(ds)
      pe.type = EVENT_TYPE
      pe.detail = EVENT_DETAIL
      return pe
    end

    def validate_ds_checksum!(ds)
      pe = self.validate_ds_checksum(ds)
      pe.save!
      self.fixity_checks << pe
      return pe
    end

    # def validate_ds_checksums
    #   validations = []
    #   self.reload # ensure that AF object datastreams are in sync with Fedora
    #   self.datastreams.each_value do |ds|
    #     ds.versions.each do |ds_version| 
    #       validation = self.validate_ds_checksum(ds_version)
    #       next if validation[:dsProfile].empty? || validation[:dsProfile]["dsChecksumType"] == "DISABLED"
    #       validations << validation
    #     end
    #   end        
    #   return validations
    # end

    # def validate_checksums!
    #   self.validate_checksums.each do |e|
    #     pe = PreservationEvent.new(:label => EVENT_DETAIL)
    #     pe.linking_obj_id_type = LINKING_OBJECT_ID_TYPE
    #     pe.linking_obj_id_value = linking_object_id_value(e[:dsID], e[:dsProfile]["dsCreateDate"])
    #     pe.type = EVENT_TYPE
    #     pe.detail = EVENT_DESCRIPTION
    #     pe.datetime = e[:validationDate].strftime("%Y-%m-%dT%H:%M:%S.%LZ")
    #     pe.outcome = e[:dsProfile]["dsChecksumValid"] ? EVENT_OUTCOME_PASSED : EVENT_OUTCOME_FAILED
    #     pe.save!
    #     self.fixity_checks << pe
    #   end
    # end

    def linking_object_id_value(ds)
      "info:fedora/#{ds.pid}/datastreams/#{ds.dsid}?asOfDateTime=#{ds.profile['dsCreateDate'].strftime(DATASTREAM_DATE_TIME_FORMAT)}"
    end

  end
end
