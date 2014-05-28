module DulHydra
  module Configurable
    extend ActiveSupport::Concern

    included do
      mattr_accessor :unwanted_models

      # Columns in the CSV report generated for a collection
      # Each column represents a *method* of a SolrDocument
      # See DulHydra::SolrDocument
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

      # Superuser group
      mattr_accessor :superuser_group

      # Contact email address
      mattr_accessor :contact_email

      # Default CSV options
      mattr_accessor :csv_options

      # List of models that may appear on a "create" menu (if user has ability)
      mattr_accessor :create_menu_models
      self.create_menu_models = []
    end

    module ClassMethods
      def configure
        yield self
      end
    end

  end
end
