module DulHydra::Configurable
  extend ActiveSupport::Concern

  included do
    mattr_accessor :unwanted_models

    mattr_accessor :export_set_manifest_file_name

    # Columns in the CSV report generated for a collection
    # Each column represents a *method* of a SolrDocument
    # See DulHydra::Models::SolrDocument
    mattr_accessor :collection_report_fields

    ## Remote groups (i.e., Grouper) config settings
    # request.env key for group memberships
    mattr_accessor :remote_groups_env_key

    # request.env value internal delimiter
    mattr_accessor :remote_groups_env_value_delim

    # pattern/repl for converting request.env membership values to proper (Grouper) group names
    mattr_accessor :remote_groups_env_value_sub

    # Filter for getting list of remote groups for the repository - String, not Regexp
    mattr_accessor :remote_groups_name_filter

    # Ability-Group mappings
    mattr_accessor :ability_group_map
    self.ability_group_map = {}

    # Repository content models that can be created through the web
    # List model names as strings not classes.
    mattr_accessor :creatable_models
    self.creatable_models = []

    mattr_accessor :terms_for_creating

    # Superuser group
    mattr_accessor :superuser_group
  end

  module ClassMethods
    def configure
      yield self
    end
  end

end
