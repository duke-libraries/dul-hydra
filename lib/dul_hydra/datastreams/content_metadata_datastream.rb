module DulHydra::Datastreams

  class ContentMetadataDatastream < DulHydra::Datastreams::FileContentDatastream
    
    def parse
      parsed = []
      cm = Nokogiri::XML(self.content)
      structMap_nodes = cm.xpath("//xmlns:structMap").sort{ |x,y| sort_nodes(x, y) }
      structMap_nodes.each do |structMap_node|
        div0_nodes = structMap_node.xpath("xmlns:div").sort{ |x,y| sort_nodes(x,y) }
        div0_nodes.each do |div0_node|
          div1_nodes = div0_node.xpath("xmlns:div").sort{ |x,y| sort_nodes(x, y) }
          div1_nodes.each do |div1_node|
            parsed << div1_node.xpath("xmlns:fptr").first["FILEID"]
          end
        end
      end
      return parsed
    end
    
    private
    
    def sort_nodes(node_1, node_2)
      if node_1["ORDER"].nil? && node_2["ORDER"].nil?
        return 0
      elsif node_1["ORDER"].nil?
        return 1
      elsif node_2["ORDER"].nil?
        return -1
      else
        return node_1["ORDER"].to_i <=> node_2["ORDER"].to_i
      end
    end
    
  end
end