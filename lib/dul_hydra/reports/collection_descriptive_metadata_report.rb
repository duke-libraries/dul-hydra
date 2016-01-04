module DulHydra::Reports
  class CollectionDescriptiveMetadataReport < CollectionReport

    def initialize(collection, **args)
      super(collection, **args) do
        is_member_of_collection collection
        model "Item"
        fields :id, :permanent_id, :local_id, Ddr::Index::Fields.descmd
      end
    end

    def default_title
      super + "__DESCMD"
    end

  end
end
