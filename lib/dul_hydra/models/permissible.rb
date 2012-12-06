module DulHydra::Models
  module Permissible

    ADMIN_GROUP_NAME = "repositoryAdmin"
    EDITOR_GROUP_NAME = "repositoryEditor"
    READER_GROUP_NAME = "repositoryReader"

    PUBLIC_READ_ACCESS = {:name => "public", :type => "group", :access => "read"}
    PUBLIC_DISCOVER_ACCESS = {:name => "public", :type => "group", :access => "discover"}
    REGISTERED_READ_ACCESS = {:name => "registered", :type => "group", :access => "read"}

    READER_GROUP_ACCESS = {:name => READER_GROUP_NAME, :type => "group", :access => "read"}
    EDITOR_GROUP_ACCESS = {:name => EDITOR_GROUP_NAME, :type => "group", :access => "edit"}
    ADMIN_GROUP_ACCESS = {:name => ADMIN_GROUP_NAME, :type => "group", :access => "edit"}

    DEFAULT_PERMISSIONS = [PUBLIC_READ_ACCESS, EDITOR_GROUP_ACCESS, ADMIN_GROUP_ACCESS]

    def grant_public_read_access
      permissions = [PUBLIC_READ_ACCESS]
    end

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
