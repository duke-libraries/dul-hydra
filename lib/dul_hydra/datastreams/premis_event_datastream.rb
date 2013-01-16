require 'securerandom'

module DulHydra::Datastreams

  class PremisEventDatastream < ActiveFedora::NokogiriDatastream

    PREMIS_VERSION = "2.2"
    PREMIS_XMLNS = "info:lc/xmlns/premis-v2"
    PREMIS_SCHEMA = "http://www.loc.gov/standards/premis/v2/premis.xsd"
    
    #
    # PREMIS terminology based on version 2.2 of PREMIS standard
    # http://www.loc.gov/standards/premis/v2/premis-2-2.pdf
    #
    set_terminology do |t|
      t.root(:path => "event", :xmlns => PREMIS_XMLNS, :schema => PREMIS_SCHEMA)
      t.identifier(:path => "eventIdentifier") {
        t.type(:path => "eventIdentifierType")
        t.value(:path => "eventIdentifierValue")
      }
      t.type(:path => "eventType")
      t.datetime(:path => "eventDateTime")
      t.detail(:path => "eventDetail")
      t.outcome_information(:path => "eventOutcomeInformation") { 
        t.outcome(:path => "eventOutcome")
        t.detail(:path => "eventOutcomeDetail") {
          t.note(:path => "eventOutcomeDetailNote")
        }
      }
      t.linking_object_id(:path => "linkingObjectIdentifier") {
        t.type(:path => "linkingObjectIdentifierType")
        t.value(:path => "linkingObjectIdentifierValue")
      }
    end
    
    def self.xml_template
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.event(:xmlns => PREMIS_XMLNS, 
                   "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
                   "xsi:schemaLocation" => "#{PREMIS_XMLNS} #{PREMIS_SCHEMA}",
                  :version => PREMIS_VERSION) {
          xml.eventIdentifier {
            xml.eventIdentifierType("UUID")
            xml.eventIdentifierValue(SecureRandom.uuid)
          }
        }
      end
      return builder.doc
    end

  end

end
