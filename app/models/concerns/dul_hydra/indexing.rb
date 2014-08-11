module DulHydra
  module Indexing

    def to_solr(solr_doc=Hash.new, opts={})
      solr_doc = super(solr_doc, opts)
      solr_doc.merge index_fields
    end

    def index_fields
      fields = {
        DulHydra::IndexFields::TITLE => title_display,
        DulHydra::IndexFields::INTERNAL_URI => internal_uri,
        DulHydra::IndexFields::IDENTIFIER => identifier_sort
      }
      if respond_to? :fixity_checks
        last_fixity_check = fixity_checks.last
        fields.merge!(last_fixity_check.to_solr) if last_fixity_check
      end
      if respond_to? :virus_checks
        last_virus_check = virus_checks.last
        fields.merge!(last_virus_check.to_solr) if last_virus_check
      end
      if respond_to?(:original_filename) && original_filename.present?
        fields[DulHydra::IndexFields::ORIGINAL_FILENAME] = original_filename
      end
      if has_content?
        fields[DulHydra::IndexFields::CONTENT_SIZE] = content_size
        fields[DulHydra::IndexFields::CONTENT_SIZE_HUMAN] = content_human_size
        fields[DulHydra::IndexFields::MEDIA_TYPE] = content_type
        fields[DulHydra::IndexFields::MEDIA_MAJOR_TYPE] = content_major_type
        fields[DulHydra::IndexFields::MEDIA_SUB_TYPE] = content_sub_type
      end
      fields
    end

    def title_display
      return title.first if title.present?
      return identifier.first if identifier.present?
      return original_filename if respond_to?(:original_filename) && original_filename.present?
      "[#{pid}]"
    end

    def identifier_sort
      identifier.first
    end

  end
end
