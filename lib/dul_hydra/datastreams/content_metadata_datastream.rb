module DulHydra::Datastreams

  class ContentMetadataDatastream < DulHydra::Datastreams::FileContentDatastream
    
    def parse
      parsed = []
      cm = Nokogiri::XML(self.content)
      fileSec_nodes = cm.xpath("//xmlns:fileSec")
      structMap_nodes = cm.xpath("//xmlns:structMap").sort{ |x,y| sort_nodes(x, y) }
      structMap_nodes.each do |structMap_node|
        structMap_hash = {}
        div_nodes = structMap_node.xpath("xmlns:div").sort{ |x,y| sort_nodes(x,y) }
        div_array = []
        div_nodes.each do |div_node|
          div_array << parse_div(fileSec_nodes, div_node)
        end
        structMap_hash[:div] = div_array
        parsed << structMap_hash
      end
      return parsed
    end
    
    private
    
    def parse_div(fileSec_nodes, div_node)
      div_hash = {}
      div_hash[:label] = div_node["LABEL"] unless div_node["LABEL"].nil?
      div_hash[:orderlabel] = div_node["ORDERLABEL"] unless div_node["ORDERLABEL"].nil?
      div_hash[:type] = div_node["TYPE"] unless div_node["TYPE"].nil?
      div_subnodes = div_node.xpath("xmlns:div").sort{ |x,y| sort_nodes(x, y) }
      if div_subnodes.empty?
        fptr_nodes = div_node.xpath("xmlns:fptr")
        fptr_array = []
        fptr_nodes.each do |fptr_node|
          fptr_hash = {}
          if !fptr_node["FILEID"].nil?
            pid = get_pid(fileSec_nodes, fptr_node["FILEID"])
            file_use = get_use(fileSec_nodes, fptr_node["FILEID"])
            fptr_hash[:pid] = pid unless pid.nil?
            fptr_hash[:use] = file_use unless file_use.nil?
          end
          fptr_array << fptr_hash
        end
        div_hash[:pids] = fptr_array
      else
        div_array = []
        div_subnodes.each do |div_subnode|
          div_array << parse_div(fileSec_nodes, div_subnode)
        end
        div_hash[:div] = div_array
      end
      return div_hash
    end
    
    def get_use(fileSec_nodes, file_id)
      file_nodes = fileSec_nodes.xpath("//xmlns:file[@ID='#{file_id}']")
      file_node =
      case file_nodes.size
      when 1
        file_nodes.first
      when 0
        raise "Matching file node not found"
      else
        raise "Multiple matching file nodes found"
      end
      return find_use(file_node)
    end
    
    def find_use(node)
      file_use = nil
      if node["USE"].nil?
        file_use = find_use(node.parent) unless node.name.eql?("fileGrp")
      else
        file_use = node["USE"]
      end
      return file_use
    end
    
    def get_pid(fileSec_nodes, file_id)
      file_nodes = fileSec_nodes.xpath("//xmlns:file[@ID='#{file_id}']")
      file_node =
      case file_nodes.size
      when 1
        file_nodes.first
      when 0
        raise "Matching file node not found"
      else
        raise "Multiple matching file nodes found"
      end
      fLocat_nodes = file_node.xpath("xmlns:FLocat")
      fLocat_node =
      case fLocat_nodes.size
      when 1
        fLocat_nodes.first
      when 0
        raise "FLocat node not found"
      else
        raise "Multiple FLocat nodes found"
      end
      href = fLocat_node["xlink:href"]
      pid = href.split('/')[0]
    end
    
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