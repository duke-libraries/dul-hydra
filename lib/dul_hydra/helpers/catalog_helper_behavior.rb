module DulHydra::Helpers
  module CatalogHelperBehavior
    
    def internal_uri_to_pid(args)
      ActiveFedora::Base.pids_from_uris(args[:document][args[:field]])
    end

    def display_sm(sm)
      display = ""
      if sm.has_key?("div")
        pids = walk_div(sm["div"], "pids", [])
        children_info = get_children_info(pids)
        walk_div(sm["div"], "display", display, children_info)
      end
      return display
    end
    
    def walk_div(div, mode, collector, children_info=nil)
      div.each do |d|
        collector << d["label"] if mode.eql?("display") && d.has_key?("label")
        if d.has_key?("div")
          walk_div(d["div"], mode, collector, children_info)
        else
          walk_pids(d["pids"], mode, collector, children_info)
        end
      end
      return collector
    end
    
    def walk_pids(pids, mode, collector, children_info=nil)
      collector << "<ul>" if mode.eql?("display")
      pids.each do |pid|
        collector << case mode
        when "pids"
          pid["pid"]
        when "display"
          "<li>" << link_to(children_info[pid["pid"]]["title_display"], catalog_path(pid["pid"])) << " [" << pid["use"] << "]</li>"
        end
      end
      collector << "</ul>" if mode.eql?("display")
      return collector
    end
    
    def get_children_info(pids)
      children_info = {}
      query = ActiveFedora::SolrService.construct_query_for_pids(pids)
      children = ActiveFedora::SolrService.query(query, :rows => 999)
      children.each do |child|
        children_info[child["id"]] = child
      end
      return children_info
    end
    
  end
end
