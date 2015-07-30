module DulHydra
  module Configurable
    extend ActiveSupport::Concern

    included do
      # Technical metadata fields to display on the show page
      # of a content object.
      # See Ddr::Managers::TechnicalMetadataManager.
      mattr_accessor :tech_metadata_fields do
        [ :format_label,
          :format_version,
          :media_type,
          :pronom_identifier,
          :creating_application,
          :valid,
          :well_formed,
          :file_human_size,
          :image_width,
          :image_height,
          :color_space,
          :created,
          :last_modified,
          :checksum_digest,
          :checksum_value,
        ]
      end

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

      # Group authorized to upload metadata files
      mattr_accessor :metadata_file_creators_group

      # Context used in alert message selection
      mattr_accessor :alert_message_context
    end

    module ClassMethods
      def configure
        yield self
      end
    end

  end
end

