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
          :message,
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
        [ Ddr::Index::Fields::TECHMD_FORMAT_LABEL,
          Ddr::Index::Fields::TECHMD_FORMAT_VERSION,
          Ddr::Index::Fields::TECHMD_MEDIA_TYPE,
          Ddr::Index::Fields::TECHMD_PRONOM_IDENTIFIER,
          Ddr::Index::Fields::TECHMD_CREATING_APPLICATION,
          Ddr::Index::Fields::TECHMD_VALID,
          Ddr::Index::Fields::TECHMD_WELL_FORMED,
          Ddr::Index::Fields::TECHMD_FILE_SIZE,
          Ddr::Index::Fields::TECHMD_CREATION_TIME,
          Ddr::Index::Fields::TECHMD_MODIFICATION_TIME,
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

      # Context used in alert message selection
      mattr_accessor :alert_message_context

      mattr_accessor :fixity_check_limit do
        ENV["FIXITY_CHECK_LIMIT"] || 10**5
      end

      mattr_accessor :fixity_check_period_in_days do
        ENV["FIXITY_CHECK_PERIOD"] || 60
      end

      # Base path for METS folders
      mattr_accessor :mets_folder_base_path

      mattr_accessor :python do
        File.join(Rails.root, "python")
      end

    end

    module ClassMethods
      def configure
        yield self
      end
    end

  end
end

