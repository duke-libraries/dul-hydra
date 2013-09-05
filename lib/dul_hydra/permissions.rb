module DulHydra::Permissions
    PUBLIC_GROUP = "public"
    REGISTERED_GROUP = "registered"
  
    BUILTIN_GROUPS = [ PUBLIC_GROUP, REGISTERED_GROUP ]

    ADMIN_GROUP_NAME = "repositoryAdmin"
    EDITOR_GROUP_NAME = "repositoryEditor"
    READER_GROUP_NAME = "repositoryReader"
    
    DISCOVER_ACCESS = "discover"
    READ_ACCESS = "read"
    EDIT_ACCESS = "edit"
    
    BASE_ACCESSES = [ DISCOVER_ACCESS, READ_ACCESS, EDIT_ACCESS ]

    PUBLIC_READ_ACCESS = {:name => "public", :type => "group", :access => "read"}
    PUBLIC_DISCOVER_ACCESS = {:name => "public", :type => "group", :access => "discover"}
    REGISTERED_READ_ACCESS = {:name => "registered", :type => "group", :access => "read"}
    REGISTERED_DISCOVER_ACCESS = {:name => "registered", :type => "group", :access => "discover"}

    READER_GROUP_ACCESS = {:name => READER_GROUP_NAME, :type => "group", :access => "read"}
    EDITOR_GROUP_ACCESS = {:name => EDITOR_GROUP_NAME, :type => "group", :access => "edit"}
    ADMIN_GROUP_ACCESS = {:name => ADMIN_GROUP_NAME, :type => "group", :access => "edit"}

    DEFAULT_PERMISSIONS = [PUBLIC_READ_ACCESS, EDITOR_GROUP_ACCESS, ADMIN_GROUP_ACCESS]
end
