require 'securerandom'

module DulHydra::Datastreams

  class PremisEventDatastream < ActiveFedora::OmDatastream

    PREMIS_VERSION = "2.2"
    PREMIS_XMLNS = "info:lc/xmlns/premis-v2"
    PREMIS_SCHEMA = "http://www.loc.gov/standards/premis/v2/premis.xsd"
    
    #
    # PREMIS terminology based on version 2.2 of PREMIS standard
    # http://www.loc.gov/standards/premis/v2/premis-2-2.pdf
    #
    set_terminology do |t|
      t.root(:path => "event", :xmlns => PREMIS_XMLNS, :schema => PREMIS_SCHEMA)
      t.event_identifier(:path => "eventIdentifier") {
        t.type(:path => "eventIdentifierType")
        t.value(:path => "eventIdentifierValue")
      }
      t.event_type(:path => "eventType")
      t.event_date_time(:path => "eventDateTime")
      t.event_detail(:path => "eventDetail")
      t.event_outcome_information(:path => "eventOutcomeInformation") { 
        t.outcome(:path => "eventOutcome")
        t.detail(:path => "eventOutcomeDetail") {
          t.note(:path => "eventOutcomeDetailNote")
          t.extension(:path => "eventOutcomeDetailExtension")
        }
      }
      t.linking_object_identifier(:path => "linkingObjectIdentifier") {
        t.type(:path => "linkingObjectIdentifierType")
        t.value(:path => "linkingObjectIdentifierValue")
      }
      
      # proxy terms
      t.event_id_type(:proxy => [:event_identifier, :type])
      t.event_id_value(:proxy => [:event_identifier, :value])
      t.event_outcome(:proxy => [:event_outcome_information, :outcome])
      t.event_outcome_detail_note(:proxy => [:event_outcome_information, :detail, :note])
      t.linking_object_id_type(:proxy => [:linking_object_identifier, :type])
      t.linking_object_id_value(:proxy => [:linking_object_identifier, :value])
    end
    
    def self.xml_template
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.event(:xmlns => PREMIS_XMLNS, 
                   "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
                   "xsi:schemaLocation" => "#{PREMIS_XMLNS} #{PREMIS_SCHEMA}",
                  :version => PREMIS_VERSION) {
          xml.eventDetail("DulHydra version #{DulHydra::VERSION}")
          xml.eventIdentifier {
            xml.eventIdentifierType(PreservationEvent::UUID)
            xml.eventIdentifierValue(SecureRandom.uuid)
          }
        }
      end
      return builder.doc
    end

  end

end
