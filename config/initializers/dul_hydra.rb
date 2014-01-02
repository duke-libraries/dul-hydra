require 'dul_hydra'
require 'dul_hydra/decorators/active_fedora/base_decorator'
require 'dul_hydra/decorators/active_fedora/datastream_decorator'

DulHydra.configure do |config|
  config.export_set_manifest_file_name = "README.txt"
  config.collection_report_fields = [:pid, :identifier, :content_size]
  config.remote_groups_env_key = "ismemberof"
  config.remote_groups_env_value_delim = ";"
  config.remote_groups_env_value_sub = [/^urn:mace:duke\.edu:groups/, "duke"]
  config.remote_groups_name_filter = "duke:library:repository:ddr:"
  config.terms_for_creating = [:title, :description]
  config.extra_ability_logic = [:discover_permissions, 
                                :export_sets_permissions, 
                                :preservation_events_permissions,
                                :batches_permissions,
                                :ingest_folders_permissions,
                                :metadata_files_permissions,
                                :download_permissions
                               ]
  if File.exists? "#{Rails.root}/config/ability_group_map.yml"
    config.ability_group_map = YAML.load_file("#{Rails.root}/config/ability_group_map.yml").with_indifferent_access
  end
  config.creatable_models = ["AdminPolicy", "Collection"]
end

# Load configuration for Grouper service, if present
if File.exists? "#{Rails.root}/config/grouper.yml"
  require 'dul_hydra/services/grouper_service'
  DulHydra::Services::GrouperService.config = YAML.load_file("#{Rails.root}/config/grouper.yml")[Rails.env]
end

# Load and configure devise-remote-user plugin
require 'devise_remote_user'
DeviseRemoteUser.configure do |config|
  config.auto_create = true
  config.attribute_map = {
    email: 'mail', 
    first_name: 'givenName',
    middle_name: 'duMiddleName1',
    nickname: 'eduPersonNickname',
    last_name: 'sn',
    display_name: 'displayName'
  }
  config.auto_update = true
end

# Integration of remote (Grouper) groups via Shibboleth
Warden::Manager.after_set_user do |user, auth, opts|
  user.group_service = DulHydra::Services::RemoteGroupService.new(auth.env)
end
