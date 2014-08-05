module DulHydra
  class Base < ActiveFedora::Base

    include Describable
    include Governable
    include AccessControllable
    include Licensable
    include HasProperties
    include HasThumbnail
    include ActiveFedora::Auditable
    include EventLoggable
    include Validations
    include FixityCheckable
    include FileManagement

    def to_solr(solr_doc=Hash.new, opts={})
      solr_doc = super(solr_doc, opts)
      solr_doc.merge!(DulHydra::IndexFields::TITLE => title_display,
                      DulHydra::IndexFields::INTERNAL_URI => internal_uri,
                      DulHydra::IndexFields::IDENTIFIER => identifier_sort)
      if respond_to? :fixity_checks
        last_fixity_check = fixity_checks.last
        solr_doc.merge!(last_fixity_check.to_solr) if last_fixity_check
      end
      if respond_to? :virus_checks
        last_virus_check = virus_checks.last
        solr_doc.merge!(last_virus_check.to_solr) if last_virus_check
      end
      if respond_to? :original_filename
        solr_doc.merge!(DulHydra::IndexFields::ORIGINAL_FILENAME => original_filename)
      end
      solr_doc
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

    def copy_admin_policy_or_permissions_from(other)
      copy_permissions_from(other) unless copy_admin_policy_from(other)
    end

    def association_query(association)
      # XXX Ideally we would include a clause to limit by AF model, but this should suffice
      ActiveFedora::SolrService.construct_query_for_rel(reflections[association].options[:property] => internal_uri)
    end

  end
end
