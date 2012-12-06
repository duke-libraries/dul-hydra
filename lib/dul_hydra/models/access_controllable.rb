module DulHydra::Models
  module AccessControllable
    extend ActiveSupport::Concern

    included do
      # add rightsMetadata datastream with Hydra XML terminology
      has_metadata :name => "rightsMetadata", :type => Hydra::Datastream::RightsMetadata
      #before_save :require_access_control
    end

    # adds methods for managing Hydra rightsMetadata content
    include Hydra::ModelMixins::RightsMetadata

    DEFAULT_PERMISSIONS = [{type: 'group', name: 'public', access: 'read'},
                           {type: 'group', name: 'repositoryEditor', access: 'edit'}]

    def clear_permissions
      self.discover_groups = []
      self.read_groups = []
      self.edit_groups = []
      self.discover_users = []
      self.read_users = []
      self.edit_users = []
    end

    def clear_permissions!
      # In hydra-head-5.0.0.rc1 and later, this should be replaceable by
      # rightsMetadata.clear_permissions!
      self.clear_permissions
      self.save!
    end

    def set_default_permissions
      if !permissions.empty? 
        clear_permissions
      end
      permissions = DEFAULT_PERMISSIONS
    end

    def set_default_permissions!
      set_default_permissions
      save!
    end

    # protected

    #
    # For setting default permissions (and thus creating the rightsMetadata datastream)
    # on a object at create time (technically the first save) that has been assigned 
    # neither permissions nor an admin policy object to govern access control.
    # 
    # def require_access_control
    #   if self.new_object? && self.admin_policy.nil? && self.permissions.empty?
    #     self.permissions = DEFAULT_PERMISSIONS
    #   end
    # end

  end # module
end # module
