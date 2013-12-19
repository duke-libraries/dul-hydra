module DulHydra::Datastreams
  
  class PropertiesDatastream < ActiveFedora::OmDatastream
    set_terminology do |t|
      t.root(:path => "fields")
      t.descmetadata_ {
        t.source
      }
      
      t.descmetadata_source(:proxy=>[:descmetadata, :source])
    end
    
    def self.xml_template
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.fields
      end
      builder.doc
    end
  end
  
end