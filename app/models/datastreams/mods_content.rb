class ModsContent < ActiveFedora::NokogiriDatastream
    
  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", 
           :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-4.xsd")
    t.title_info(:path=>"titleInfo") {
      t.main_title(:path=>"title", :label=>"title")
    }
    t.title(:proxy=>[:title_info, :main_title])
    t.identifier(:index_as=>[:searchable], :data_type=>:symbol)
  end
    
  def self.xml_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.mods(:version=>"3.3", "xmlns:xlink"=>"http://www.w3.org/1999/xlink",
               "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
               "xmlns"=>"http://www.loc.gov/mods/v3",
               "xsi:schemaLocation"=>"http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd") {
        xml.titleInfo {
          xml.title
        }
        xml.identifier
      }
    end
    return builder.doc
  end
end
