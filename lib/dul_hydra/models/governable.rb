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
      admin_policy.datastreams[DulHydra::Datastreams::DEFAULT_RIGHTS] if admin_policy
    end

    # Creates convenience methods: 
    # inherited_discover_users, inherited_discover_groups, 
    # inherited_read_users, inherited_read_groups,
    # inherited_edit_user, inherited_edit_groups
    ["discover", "read", "edit"].each do |access|
      ["user", "group"].each do |type|
        define_method("inherited_#{access}_#{type}s") do
          admin_policy ? admin_policy.send("default_#{access}_#{type}s") : []
        end
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
