module DulHydra::Reports
  class CollectionReport < Report

    attr_reader :collection

    def initialize(collection, **args, &block)
      @collection = collection
      super(**args, &block)
    end

    def default_title
      collection.title_display
    end

  end
end
