module DulHydra
  module Datastreams  
    class PropertiesDatastream < ActiveFedora::OmDatastream

      set_terminology do |t|
        t.root(:path => "fields")
        t.original_filename
      end
      
      def self.xml_template
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.fields
        end
        builder.doc
      end

    end
  end
end
