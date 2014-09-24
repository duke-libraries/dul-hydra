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

      # Help URL
      mattr_accessor :help_url

      # Default CSV options
      mattr_accessor :csv_options

      # List of models that may appear on a "create" menu (if user has ability)
      mattr_accessor :create_menu_models
      self.create_menu_models = []

      # Base directory of external file store
      mattr_accessor :external_file_store      

      # Regexp for building external file subpath from hex digest
      mattr_accessor :external_file_subpath_regexp
      
      # Pattern (template) for constructing noids
      mattr_accessor :noid_template

      # Noid minter state file location
      mattr_accessor :minter_statefile
    end

    module ClassMethods
      def configure
        yield self
      end

      def external_file_store= (directory)
        unless File.directory?(directory)
          raise "External file store not found: #{directory}"
        end
        unless File.writable?(directory) 
          raise "External file store not writable: #{directory}"
        end
      end

      def external_file_subpath_pattern= (pattern)
        unless /^-{1,2}(\/-{1,2}){0,3}$/ =~ pattern
          raise "Invalid external file subpath pattern: #{pattern}"
        end
        re = pattern.split("/").map { |x| "(\\h{#{x.length}})" }.join("")
        self.external_file_subpath_regexp = Regexp.new("^#{re}")
      end
    end

  end
end

