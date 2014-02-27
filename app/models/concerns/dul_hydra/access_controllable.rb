module DulHydra
  module AccessControllable
    extend ActiveSupport::Concern

    included do
      # adds methods for managing Hydra rightsMetadata content
      include Hydra::AccessControls::Permissions unless include? Hydra::AccessControls::Permissions
    end

    def set_initial_permissions(user_creator = nil)
      if user_creator
        self.permissions_attributes = [{type: "user", access: "edit", name: user_creator.to_s}]
      end
    end

    def set_initial_permissions!(user_creator = nil)
      set_initial_permissions
      save if changed?
    end

    def copy_permissions_from(other)
      # XXX active-fedora < 7.0
      self.permissions_attributes = other.permissions.collect { |p| p.to_hash }
    end

  end
end
