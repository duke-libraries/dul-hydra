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
    include Indexing

    def copy_admin_policy_or_permissions_from(other)
      copy_permissions_from(other) unless copy_admin_policy_from(other)
    end

    def association_query(association)
      # XXX Ideally we would include a clause to limit by AF model, but this should suffice
      ActiveFedora::SolrService.construct_query_for_rel(reflections[association].options[:property] => internal_uri)
    end

    # e.g., "Collection duke:1"
    def model_pid
      [self.class.to_s, pid].join(" ")
    end

  end
end
