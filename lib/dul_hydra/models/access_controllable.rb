module DulHydra::Models
  module AccessControllable
    extend ActiveSupport::Concern

    included do
      # add rightsMetadata datastream with Hydra XML terminology
      has_metadata :name => "rightsMetadata", :type => Hydra::Datastream::RightsMetadata
      after_create :require_access_control!
    end

    # adds methods for managing Hydra rightsMetadata content
    include Hydra::ModelMixins::RightsMetadata

    PUBLIC_READ_PERMISSION = {name: 'public', access: 'read', type: 'group'}
    REPOSITORY_EDITOR_PERMISSION = {name: 'repositoryEditor', access: 'edit', type: 'group'}
    DEFAULT_PERMISSIONS = [PUBLIC_READ_PERMISSION, REPOSITORY_EDITOR_PERMISSION]

    protected

    #
    # For setting default permissions (and thus creating the rightMetadata datastream)
    # on a object at create time that has not been assigned either permissions or an
    # admin policy object to govern access control.
    # 
    def require_access_control!
      if admin_policy.nil? && permissions.empty?
        permissions = DEFAULT_PERMISSIONS
        save
      end
    end

  end # module
end # module
