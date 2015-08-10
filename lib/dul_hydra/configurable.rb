module DulHydra
  module Configurable
    extend ActiveSupport::Concern

    included do
      # Technical metadata fields to display on the show page
      # of a content object.
      # See Ddr::Managers::TechnicalMetadataManager.
      mattr_accessor :techmd_show_fields do
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
          :creation_time,
          :modification_time,
          :checksum_digest,
          :checksum_value,
        ]
      end

      mattr_accessor :techmd_report_fields do
        [ Ddr::IndexFields::TECHMD_FORMAT_LABEL,
          Ddr::IndexFields::TECHMD_FORMAT_VERSION,
          Ddr::IndexFields::TECHMD_MEDIA_TYPE,
          Ddr::IndexFields::TECHMD_PRONOM_IDENTIFIER,
          Ddr::IndexFields::TECHMD_CREATING_APPLICATION,
          Ddr::IndexFields::TECHMD_VALID,
          Ddr::IndexFields::TECHMD_WELL_FORMED,
          Ddr::IndexFields::TECHMD_FILE_SIZE,
          Ddr::IndexFields::TECHMD_CREATION_TIME,
          Ddr::IndexFields::TECHMD_MODIFICATION_TIME,
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

