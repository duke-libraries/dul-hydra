require 'dul_hydra'
require 'dul_hydra/decorators/active_fedora/base_decorator'

DulHydra.configure do |config|
  config.export_set_manifest_file_name = "README.txt"
  config.collection_report_fields = [:pid, :identifier, :content_size]
  config.remote_groups_env_key = "ismemberof"
  config.remote_groups_env_value_delim = ";"
  config.remote_groups_env_value_sub = [/^urn:mace:duke\.edu:groups/, "duke"]
  config.remote_groups_name_filter = "duke:library:repository:ddr:"
  config.component_download_group = "duke:library:repository:ddr:component_download"
  config.extra_ability_logic = [:discover_permissions, 
                              :export_sets_permissions, 
                              :preservation_events_permissions,
                              :batches_permissions,
                              :ingest_folders_permissions,
                              :download_permissions
                             ]
  if File.exists? "#{Rails.root}/config/groups.yml"
    config.groups = YAML.load_file("#{Rails.root}/config/groups.yml")
  end
end
