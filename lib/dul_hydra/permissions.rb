module DulHydra::Permissions
    ADMIN_GROUP_NAME = "repositoryAdmin"
    EDITOR_GROUP_NAME = "repositoryEditor"
    READER_GROUP_NAME = "repositoryReader"

    PUBLIC_READ_ACCESS = {:name => "public", :type => "group", :access => "read"}
    PUBLIC_DISCOVER_ACCESS = {:name => "public", :type => "group", :access => "discover"}
    REGISTERED_READ_ACCESS = {:name => "registered", :type => "group", :access => "read"}
    REGISTERED_DISCOVER_ACCESS = {:name => "registered", :type => "group", :access => "discover"}

    READER_GROUP_ACCESS = {:name => READER_GROUP_NAME, :type => "group", :access => "read"}
    EDITOR_GROUP_ACCESS = {:name => EDITOR_GROUP_NAME, :type => "group", :access => "edit"}
    ADMIN_GROUP_ACCESS = {:name => ADMIN_GROUP_NAME, :type => "group", :access => "edit"}

    DEFAULT_PERMISSIONS = [PUBLIC_READ_ACCESS, EDITOR_GROUP_ACCESS, ADMIN_GROUP_ACCESS]
end
