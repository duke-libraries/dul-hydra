module DulHydra::Configurable
  extend ActiveSupport::Concern

  included do
    # Ordering of descriptive metadata fields on object page
    mattr_accessor :metadata_fields
    self.metadata_fields = [:title, :identifier, :source, :description, :date, :creator, :contributor, :publisher, :language, :subject, :type, :relation, :coverage, :rights]

    mattr_accessor :unwanted_models

    mattr_accessor :export_set_manifest_file_name
    self.export_set_manifest_file_name = "README.txt"

    # Columns in the CSV report generated for a collection
    # Each column represents a *method* of a SolrDocument
    # See DulHydra::Models::SolrDocument
    mattr_accessor :collection_report_fields
    self.collection_report_fields = [:pid, :identifier, :content_size]

    ## Grouper config settings
    # request.env key for group memberships
    mattr_accessor :grouper_groups_env_key
    self.grouper_groups_env_key = "ismemberof"

    # request.env value internal delimiter
    mattr_accessor :grouper_groups_env_value_delim
    self.grouper_groups_env_value_delim = ";"

    # pattern/repl for converting request.env membership values to proper Grouper group names
    mattr_accessor :grouper_groups_env_value_sub
    self.grouper_groups_env_value_sub = [/^urn:mace:duke\.edu:groups/, "duke"]

    # Filter for getting list of Grouper groups for the repository
    mattr_accessor :grouper_groups_name_filter
    self.grouper_groups_name_filter = /^duke:library:repository:/
  end

end
