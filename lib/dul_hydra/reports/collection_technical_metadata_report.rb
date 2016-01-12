module DulHydra::Reports
  class CollectionTechnicalMetadataReport < CollectionReport

    def initialize(collection, **args)
      super(collection, **args) do
        is_governed_by collection
        has_content
        fields :id, Ddr::Index::Fields.techmd
      end
    end

    def default_title
      super + "__TECHMD"
    end

  end
end
