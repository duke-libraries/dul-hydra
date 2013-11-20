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

    # Groups authz for downloading Component content
    mattr_accessor :component_download_group

    # Methods to add to Ability initialization
    mattr_accessor :extra_ability_logic

    # Group mappings
    mattr_accessor :groups
    self.groups = {}
  end

  module ClassMethods
    def configure
      yield self
    end
  end

end
