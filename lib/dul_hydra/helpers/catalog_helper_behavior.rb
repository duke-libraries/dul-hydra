module DulHydra::Helpers
  module CatalogHelperBehavior
    
    def internal_uri_to_pid(args)
      ActiveFedora::Base.pids_from_uris(args[:document][args[:field]])
    end

    def internal_uri_to_link(args)
      pid = internal_uri_to_pid(args).first
      # Depends on Blacklight::SolrHelper#get_solr_response_for_doc_id 
      # having been added as a helper method to CatalogController
      response, doc = get_solr_response_for_doc_id(pid)
      title = doc.nil? ? pid : doc.fetch('title_display', pid)
      link_to(title, catalog_path(pid), :class => "parent-link").html_safe
    end

    def display_structure(structure)
      display = ""
      if structure.has_key?("div")
        pids = walk_structure_div(structure["div"], "pids", [])
        structure_contents_info = get_structure_contents_info(pids)
        walk_structure_div(structure["div"], "display", display, structure_contents_info)
      end
      return display
    end
    
    def walk_structure_div(structure_div, mode, collector, structure_contents_info=nil)
      structure_div.each do |div|
        collector << div["label"] if mode.eql?("display") && div.has_key?("label")
        if div.has_key?("div")
          walk_structure_div(div["div"], mode, collector, structure_contents_info)
        else
          walk_structure_pids(div["pids"], mode, collector, structure_contents_info)
        end
      end
      return collector
    end
    
    def walk_structure_pids(structure_pids, mode, collector, structure_contents_info=nil)
      collector << "<ul>" if mode.eql?("display")
      structure_pids.each do |pid|
        collector << case mode
        when "pids"
          pid["pid"]
        when "display"
          "<li>" << link_to(structure_contents_info[pid["pid"]]["title_display"], catalog_path(pid["pid"])) << " [" << pid["use"] << "]</li>"
        end
      end
      collector << "</ul>" if mode.eql?("display")
      return collector
    end
    
    def get_structure_contents_info(pids)
      structure_contents_info = {}
      query = ActiveFedora::SolrService.construct_query_for_pids(pids)
      contents_docs = ActiveFedora::SolrService.query(query, :rows => 999)
      contents_docs.each do |contents_doc|
        structure_contents_info[contents_doc["id"]] = contents_doc
      end
      return structure_contents_info
    end
    
  end
end
