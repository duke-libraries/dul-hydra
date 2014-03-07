module DulHydra
  module HasChildren
    extend ActiveSupport::Concern

    def first_child
      if datastreams.include?(DulHydra::Datastreams::CONTENT_METADATA) && datastreams[DulHydra::Datastreams::CONTENT_METADATA].has_content?
        first_child_pid = datastreams[DulHydra::Datastreams::CONTENT_METADATA].first_pid
      else
        first_child_pid = ActiveFedora::SolrService.query(children_query, rows: 1, sort: "#{DulHydra::IndexFields::IDENTIFIER} ASC").first["id"]
      end      
      begin
        ActiveFedora::Base.find(first_child_pid, :cast => true) if first_child_pid
      rescue ActiveFedora::ObjectNotFound
        nil
      end
    end

    def children_query
      children.send(:construct_query)
    end

    def set_thumbnail
      copy_thumbnail_from first_child
    end

  end
end
