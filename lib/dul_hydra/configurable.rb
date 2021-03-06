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

      # Message displayed in banner indicating a preview
      mattr_accessor :preview_banner_msg

      mattr_accessor :fixity_check_limit do
        ENV["FIXITY_CHECK_LIMIT"] || 10**4
      end

      mattr_accessor :fixity_check_period_in_days do
        ENV["FIXITY_CHECK_PERIOD"] || 60
      end

      mattr_accessor :duracloud_space do
        ENV["DURACLOUD_SPACE"]
      end

      mattr_accessor :user_editable_admin_metadata_fields do
        [
          :affiliation,
          :aleph_id,
          :aspace_id,
          :depositor,
          :display_format,
          :doi,
          :ead_id,
          :license,
          :local_id,
          :rights_note,
        ]
      end

      mattr_accessor :user_editable_item_admin_metadata_fields do
        [ :nested_path ]
      end

      # Entries per page on batches index display
      mattr_accessor :batches_per_page do
        ENV["BATCHES_PER_PAGE"] || 10
      end

      mattr_accessor :auto_assign_permanent_id do
        false
      end

      mattr_accessor :auto_update_permanent_id do
        false
      end

      mattr_accessor :auto_update_structures do
        true
      end

      # Home directory for FITS
      mattr_accessor :fits_home do
        ENV["FITS_HOME"]
      end

      # Host name for use in non-web-request situations
      mattr_accessor :host_name do
        ENV["HOST_NAME"]
      end

      # Value used in metadata export/import to separate
      # multiple values in a single CSV cell.
      mattr_accessor :csv_mv_separator do
        ENV["CSV_MV_SEPARATOR"] || "|"
      end

      # Directory to store export files
      mattr_accessor :export_files_store do
        ENV["EXPORT_FILES_STORE"] || File.join(Rails.root, "public", "export_files")
      end

      # Base URL for export files - include trailing slash
      mattr_accessor :export_files_base_url do
        ENV["EXPORT_FILES_BASE_URL"] || "/export_files/"
      end

      mattr_accessor :export_files_max_payload_size do
        if value = ENV["EXPORT_FILES_MAX_PAYLOAD_SIZE"]
          value.to_i
        else
          100 * 10**9 # 100Gb
        end
      end

      # Columns in the CSV report generated for a collection
      # Each column represents a *method* of a SolrDocument
      # See DulHydra::SolrDocument
      mattr_accessor :collection_report_fields

    end

    module ClassMethods
      def configure
        yield self
      end
    end

  end
end
