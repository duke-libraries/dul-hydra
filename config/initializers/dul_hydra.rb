require 'dul_hydra'

DulHydra.configure do |config|
  config.collection_report_fields = [:pid, :identifier, :content_size, :content_checksum]

  config.remote_groups_env_key = "ismemberof"

  config.remote_groups_env_value_delim = ";"

  config.remote_groups_env_value_sub = [/^urn:mace:duke\.edu:groups/, "duke"]

  config.remote_groups_name_filter = "duke:library:repository:ddr:"

  config.superuser_group = ENV['SUPERUSER_GROUP']

  config.contact_email = ENV['CONTACT_EMAIL']

  config.help_url = Rails.env.test? ? "http://www.loc.gov" : ENV['HELP_URL']

  config.csv_options = { 
    encoding: "UTF-8",
    col_sep: "\t",
    headers: true,
    write_headers: true,
    header_converters: :symbol
  }

  config.create_menu_models = ["Collection", "Role", "IngestFolder", "MetadataFile"]

  config.external_file_store = ENV['EXTERNAL_FILE_STORE']

  config.external_file_subpath_pattern = [1, 1, 2]
  
  config.noid_template = "2.reeddeeddk"
  
  config.minter_statefile = Rails.env.test? ? "/tmp/minter-state" : ENV['MINTER_STATEFILE']
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
  config.logout_url = "/Shibboleth.sso/Logout?return=https://shib.oit.duke.edu/cgi-bin/logout.pl"
end

# Integration of remote (Grouper) groups via Shibboleth
Warden::Manager.after_set_user do |user, auth, opts|
  user.group_service = DulHydra::Services::RemoteGroupService.new(auth.env)
end

Blacklight::Configuration.default_values[:http_method] = :post

DulHydra::Services::Antivirus.load!
