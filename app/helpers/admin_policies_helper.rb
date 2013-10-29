module AdminPoliciesHelper
  
  def permissions_select_options(include_remove)
    select_options = []
    DulHydra::Permissions::BASE_ACCESSES.each { |access| select_options << [ access ] }
    select_options << [ "**Remove**", "_remove_" ] if include_remove
    return select_options
  end
  
  def local_groups
    YAML.load(File.open(File.join(Rails.root, "config/role_map_#{Rails.env}.yml"))).keys
  end
  
  def add_group_select_options
    all_groups_options = []
    existing_groups_options = []
    default_permissions = @admin_policy.default_permissions
    default_permissions.each do |perm|
      existing_groups_options << [ perm[:name] ]
    end
    DulHydra::Permissions::BUILTIN_GROUPS.each { |group| all_groups_options << [ group ] }
    local_groups.each { |group| all_groups_options << [ group ] }
    all_groups_options - existing_groups_options
  end
  
end