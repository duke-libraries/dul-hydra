module DulHydra::Models
  module Permissible

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

  end
end
