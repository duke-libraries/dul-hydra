class CollectionsController < ApplicationController

  include Blacklight::Catalog

  before_filter :enforce_show_permissions, :only => :show

  def show
    @collection = Collection.find(params[:id])
    @items = @collection.children.size
    components_query = "{!join to=#{DulHydra::IndexFields::IS_PART_OF} from=#{DulHydra::IndexFields::INTERNAL_URI}}#{DulHydra::IndexFields::IS_MEMBER_OF_COLLECTION}:\"#{@collection.internal_uri}\""
    response, documents = get_search_results(params, {q: components_query, rows: 10000})
    @components = response.total
    @total_file_size = documents.collect {|doc| doc.datastreams["content"]["dsSize"] || 0 }.inject(:+)
  end

end
