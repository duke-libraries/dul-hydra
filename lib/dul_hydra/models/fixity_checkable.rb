module DulHydra::Models
  module FixityCheckable
    extend ActiveSupport::Concern

    FIXITY_CHECK_PASSED = "PASSED"
    FIXITY_CHECK_FAILED = "FAILED"
    FIXITY_CHECK_LINKING_OBJECT_ID_TYPE = "datastream"
    FIXITY_CHECK_DESCRIPTION = "Object datastream version checksum validation"
    FIXITY_CHECK_EVENT_TYPE = "fixity check"


    DATASTREAM_DATE_TIME_FORMAT = "%Y-%m-%dT%H:%M:%S.%LZ"

    included do
      has_many :fixity_checks, :property => :fixity_check, :inbound => true, :class_name => 'PreservationEvent'
    end

    def validate_checksums
      events = []
      self.reload # ensure that AF object datastreams are in sync with Fedora
      self.datastreams.each do |dsID, ds|
        ds.versions.each do |ds_version| 
          dsProfile = ds_version.profile(:validateChecksum => true)
          next if dsProfile.empty? || dsProfile["dsChecksumType"] == "DISABLED"
          events << {
            :dsID => dsID,
            :dsProfile => dsProfile,
            :validationDate => Time.now.utc,
          }          
        end
      end        
      return events
    end

    def validate_checksums!
      self.validate_checksums.each do |e|
        pe = PreservationEvent.new(:label => FIXITY_CHECK_DESCRIPTION)
        pe.linking_obj_id_type = FIXITY_CHECK_LINKING_OBJECT_ID_TYPE
        pe.linking_obj_id_value =  fixity_check_linking_object_id_value(e[:dsID], e[:dsProfile]["dsCreateDate"])
        pe.type = FIXITY_CHECK_EVENT_TYPE
        pe.detail = FIXITY_CHECK_DESCRIPTION
        pe.datetime = e[:validationDate].strftime("%Y-%m-%dT%H:%M:%S.%LZ")
        pe.outcome = e[:dsProfile]["dsChecksumValid"] ? FIXITY_CHECK_PASSED : FIXITY_CHECK_FAILED
        pe.save!
        self.fixity_checks << pe
      end
    end

    def fixity_check_linking_object_id_value(dsID, dsCreateDate)
      "info:fedora/#{self.pid}/datastreams/#{dsID}?asOfDateTime=#{dsCreateDate.strftime(DATASTREAM_DATE_TIME_FORMAT)}"
    end

  end
end
