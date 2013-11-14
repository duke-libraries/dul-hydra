module PermissionsHelper

  def all_permissions
    ["discover", "read", "edit"]
  end

  def user_options_for_select(permission)
    options_for_select(all_user_options, selected_user_options(permission))
  end

  def group_options_for_select(permission)
    options_for_select(all_group_options, selected_group_options(permission))
  end

  def entity_options_for_select(entity, permission)
    send "#{entity}_options_for_select", permission
  end

  def all_user_options
    @all_user_options ||= User.all.collect { |u| u.user_key }
  end

  def selected_user_options(permission)
    current_object.send("#{permission}_users")
  end

  def group_options(groups)
    groups.collect { |g| [group_option_text(g), g] }
  end

  def all_group_options
    @all_group_options ||= group_options(group_service.groups)
  end

  def selected_group_options(permission)
    current_object.send("#{permission}_groups")
  end

  def group_option_text(group_name)
    case group_name
    when Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC
      "Public"
    when Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED
      "Duke Community"
    else
      group_name
    end
  end

end
