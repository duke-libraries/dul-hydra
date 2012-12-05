module DulHydra::Models
  module AccessControllable
    extend ActiveSupport::Concern

    included do
      # add rightsMetadata datastream with Hydra XML terminology
      has_metadata :name => "rightsMetadata", :type => Hydra::Datastream::RightsMetadata
      before_save :require_access_control
    end

    # adds methods for managing Hydra rightsMetadata content
    include Hydra::ModelMixins::RightsMetadata

    REPOSITORY_EDITOR_GROUP = 'repositoryEditor'

    def clear_permissions
      self.discover_groups = []
      self.read_groups = []
      self.edit_groups = []
      self.discover_users = []
      self.read_users = []
      self.edit_users = []
    end

    def clear_permissions!
      self.clear_permissions
      self.save!
    end

    protected

    #
    # For setting default permissions (and thus creating the rightMetadata datastream)
    # on a object at create time (technically first save) that has not been assigned 
    # either permissions or an admin policy object to govern access control.
    # 
    def require_access_control
      if self.new_object? && self.admin_policy.nil? && self.permissions.empty?
        self.read_groups = ['public']
        self.edit_groups = [REPOSITORY_EDITOR_GROUP]
      end
    end

  end # module
end # module
