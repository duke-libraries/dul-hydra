module DulHydra::Configurable
  extend ActiveSupport::Concern

  included do
    mattr_accessor :unwanted_models

    mattr_accessor :export_set_manifest_file_name
    self.export_set_manifest_file_name = "README.txt"

    # Columns in the CSV report generated for a collection
    # Each column represents a *method* of a SolrDocument
    # See DulHydra::Models::SolrDocument
    mattr_accessor :collection_report_fields
    self.collection_report_fields = [:pid, :identifier, :content_size]

    ## Remote groups (i.e., Grouper) config settings
    # request.env key for group memberships
    mattr_accessor :remote_groups_env_key
    self.remote_groups_env_key = "ismemberof"

    # request.env value internal delimiter
    mattr_accessor :remote_groups_env_value_delim
    self.remote_groups_env_value_delim = ";"

    # pattern/repl for converting request.env membership values to proper (Grouper) group names
    mattr_accessor :remote_groups_env_value_sub
    self.remote_groups_env_value_sub = [/^urn:mace:duke\.edu:groups/, "duke"]

    # Filter for getting list of remote groups for the repository - String, not Regexp
    mattr_accessor :remote_groups_name_filter
    self.remote_groups_name_filter = 'duke:library:repository:ddr:'

    # Groups authz for downloading Component content
    mattr_accessor :component_download_group
    self.component_download_group = "duke:library:repository:ddr:component_download"

    # Methods to add to Ability initialization
    mattr_accessor :extra_ability_logic
    self.extra_ability_logic = [:discover_permissions, 
                                :export_sets_permissions, 
                                :preservation_events_permissions,
                                :batches_permissions,
                                :ingest_folders_permissions,
                                :download_permissions
                               ]
  end

end
