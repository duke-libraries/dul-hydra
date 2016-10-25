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
          :icc_profile_name,
          :icc_profile_version,
          :creation_time,
          :modification_time,
          :checksum_digest,
          :checksum_value,
        ]
      end

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

      mattr_accessor :fixity_check_limit do
        ENV["FIXITY_CHECK_LIMIT"] || 10**5
      end

      mattr_accessor :fixity_check_period_in_days do
        ENV["FIXITY_CHECK_PERIOD"] || 60
      end

      mattr_accessor :duracloud_space do
        ENV["DURACLOUD_SPACE"]
      end

      mattr_accessor :user_editable_admin_metadata_fields do
        [ :local_id,
          :display_format,
          :depositor,
          :doi,
          :license,
          :ead_id,
          :aspace_id ]
      end

      # Base path for Simple Ingest folders
      mattr_accessor :simple_ingest_base_path

    end

    module ClassMethods
      def configure
        yield self
      end
    end

  end
end

