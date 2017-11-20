module ArchivesSpace
  class ExportDigitalObjectInfo

    title_field = Ddr::Index::Fields.descmd.detect { |f| f == "title_tesim" } # HACK
    FIELDS = [ :id, :local_id, :aspace_id, :ead_id, :permanent_id, :permanent_url, :display_format, title_field ]

    def self.call(collection_id)
      Ddr::Index::Query.build(collection_id) do |coll|
        is_member_of_collection coll

        # This ordering is used in advance of reliable
        # ordering provided by structural metadata
        order_by local_id: :asc, object_create_date: :asc

        fields FIELDS
      end
    end

  end
end
