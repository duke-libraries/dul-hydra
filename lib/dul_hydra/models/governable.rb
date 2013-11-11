module DulHydra::Models
  module Governable
    extend ActiveSupport::Concern

    included do
      belongs_to :admin_policy, :property => :is_governed_by
    end

    def inherited_permissions
      admin_policy ? admin_policy.default_permissions : []
    end

    def inherited_rights
      admin_policy.datastreams[DulHydra::Datastreams::RIGHTS_METADATA] if admin_policy
    end

    def inherited_entities_for_permission(type, permission)
      if inherited_rights
        type = "individual" if type == "user" # Hydra < 7.0 hack
        inherited_rights.send(type.pluralize).collect { |e, perms| e if perms.include?(permission) }.compact
      else
        []
      end
    end

    # XXX Move license methods to Licensable? --dchandekstark

    def inherited_license
      if admin_policy
        {title: inherited_license_title, description: inherited_license_description, url: inherited_license_url, inherited: true}
      end
    end

    def inherited_license_title
      admin_policy.default_license_title if admin_policy
    end

    def inherited_license_description
      admin_policy.default_license_description if admin_policy
    end

    def inherited_license_url
      admin_policy.default_license_url if admin_policy
    end

  end
end
