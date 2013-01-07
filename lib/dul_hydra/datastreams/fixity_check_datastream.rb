module DulHydra::Datastreams

  class FixityCheckDatastream < ActiveFedora::NokogiriDatastream
    
    set_terminology do |t|
      t.root(:path => "fixityCheck")
      t.date_time(:path => "dateTime")
      t.outcome
      t.outcome_detail(:path => "outcomeDetail") 
    end
    
    def self.xml_template
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.fixityCheck {
          xml.dateTime
          xml.outcome
          xml.outcomeDetail 
        }
      end
      return builder.doc
    end

  end

end
