module DulHydra
  module Configurable
    extend ActiveSupport::Concern

    included do
      mattr_accessor :unwanted_models

      # Columns in the CSV report generated for a collection
      # Each column represents a *method* of a SolrDocument
      # See DulHydra::SolrDocument
      mattr_accessor :collection_report_fields

      # Contact email address
      mattr_accessor :contact_email

      # Help URL
      mattr_accessor :help_url

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

