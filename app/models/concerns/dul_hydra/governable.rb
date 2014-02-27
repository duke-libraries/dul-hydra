module DulHydra
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

    def inherited_license
      admin_policy.default_license if admin_policy
    end

    def copy_admin_policy_from(other)
      # XXX In active-fedora 7.0 can do
      # self.admin_policy = other.admin_policy
      admin_policy_id = other.admin_policy_id if other.has_admin_policy?
    end

  end
end
