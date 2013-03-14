module DulHydra::Scripts
  class UpdateKwlContentMetadata
    def self.execute
      submaster = File.open("/srv/fedora-working/ingest/KWL/component/master/master-pdf-only.xml") { |f| Nokogiri.XML(f) }
      object_nodes = submaster.xpath("/objects/object")
      object_nodes.each do |object_node|
        identifier_node = object_node.xpath("identifier")
        identifier = identifier_node.text()
        pid_node = object_node.xpath("pid")
        pid = pid_node.text()
        cmfilename = File.join('', 'srv', 'fedora-working', 'ingest', 'KWL', 'item', 'contentmetadata', "#{identifier}.xml")
        cm = File.open(cmfilename) { |f| Nokogiri.XML(f) }
        fileSec_node = cm.xpath("//xmlns:fileSec").first
        fileGrp_node = Nokogiri::XML::Node.new 'fileGrp', cm
        fileGrp_node['ID'] = 'GRP00'
        fileGrp_node['USE'] = 'Composite PDF'
        file_node = Nokogiri::XML::Node.new 'file', cm
        file_node['ID'] = 'FILE000'
        fLocat_node = Nokogiri::XML::Node.new 'FLocat', cm
        fLocat_node['xlink:href'] = "#{pid}/content"
        fLocat_node['LOCTYPE'] = 'URL'
        file_node.add_child(fLocat_node)
        fileGrp_node.add_child(file_node)
        fileSec_node.add_child(fileGrp_node)
        structMap_node = cm.xpath("//xmlns:structMap").first
        div_node = Nokogiri::XML::Node.new 'div', cm
        div_node['ID'] = 'DIV00'
        div_node['TYPE'] = 'pdf'
        div_node['LABEL'] = 'PDF'
        fptr_node = Nokogiri::XML::Node.new 'fptr', cm
        fptr_node['FILEID'] = 'FILE000'
        div_node.add_child(fptr_node)
        structMap_node.add_child(div_node)
        File.open(cmfilename, "w") { |f| cm.write_xml_to f }
        puts "Wrote updated #{cmfilename}"
      end      
    end  
  end
end