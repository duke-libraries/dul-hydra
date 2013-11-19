module PermissionsHelper

  def user_options_for_select(permission, default_permissions=false)
    options_for_select(all_user_options, selected_user_options(permission, default_permissions))
  end

  def group_options_for_select(permission, default_permissions=false)
    options_for_select(all_group_options, selected_group_options(permission, default_permissions))
  end

  def entity_options_for_select(entity, permission, default_permissions=false)
    send "#{entity}_options_for_select", permission, default_permissions
  end

  def all_user_options
    @all_user_options ||= user_options(User.order(:last_name, :first_name))
  end

  def selected_user_options(permission, default_permissions=false)
    current_object.send(default_permissions ? "default_#{permission}_users" : "#{permission}_users")
      .collect { |u| user_option_value(u) }
  end

  def group_options(groups)
    groups.collect { |g| [group_option_text(g), group_option_value(g)] }
  end

  def all_group_options
    # TODO: List public first, then registered, then rest in alpha order (?)
    @all_group_options ||= group_options(group_service.groups)
  end

  def selected_group_options(permission, default_permissions=false)
    current_object.send(default_permissions ? "default_#{permission}_groups" : "#{permission}_groups")
      .collect { |g| group_option_value(g) }
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

  def group_option_value(group_name)
    "group:#{group_name}"
  end

  def user_options(users)
    users.collect { |u| [user_option_text(u), user_option_value(u)] }
  end

  def user_option_text(user)
    user.display_name or user.user_key
  end

  def user_option_value(user_name)
    "user:#{user_name}"
  end

  def inherited_permissions_alert
    apo_link = link_to(current_object.admin_policy_id, default_permissions_path(current_object.admin_policy_id))
    alert = I18n.t('dul_hydra.permissions.alerts.inherited') % apo_link
    alert.html_safe
  end

end
