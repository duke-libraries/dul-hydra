module DulHydra::Scripts
  class Thumbnails

    def initialize(collection_pid)
      begin
        @collection = Collection.find(collection_pid, :cast => true)
      rescue ActiveFedora::ObjectNotFound
        puts "Could not find #{collection_pid}"
      end
    end

    def execute
      items = ActiveFedora::SolrService.lazy_reify_solr_results(@collection.children.load_from_solr)
      items.each do |item|
        unless item.has_thumbnail?
          component = item.first_child
          if component.has_thumbnail?
            item.thumbnail.content = component.thumbnail.content
            item.thumbnail.mime_type = component.thumbnail.mime_type
            unless item.save
              puts "Thumbnails script unable to save item #{item.id}"
            end
          end
        end
      end
      item = @collection.first_child
      if item.has_thumbnail?
        @collection.thumbnail.content = item.thumbnail.content
        @collection.thumbnail.mime_type = item.thumbnail.mime_type
        unless @collection.save
          puts "Thumbnails script unable to save collection #{collection.id}"
        end
      end
    end

    def collection
          @collection
    end

  end
end
