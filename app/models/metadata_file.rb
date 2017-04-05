class MetadataFile < ActiveRecord::Base

  include ActiveModel::Validations

  belongs_to :user, :inverse_of => :metadata_files
  has_attached_file :metadata
  do_not_validate_attachment_file_type :metadata

  validates_presence_of :metadata, :profile

  def validate_data
    begin
      as_csv_table.headers.each_with_index do |header, idx|
        unless valid_headers.include?(header.to_sym)
          errors.add(:metadata, "#{I18n.t('batch.metadata_file.error.attribute_name')}: #{header}")
        end
        if controlled_value_headers.include?(header.to_sym)
          validate_controlled_values(header, idx)
        end
      end
    rescue CSV::MalformedCSVError => e
      errors.add(:metadata, "#{I18n.t('batch.metadata_file.error.parse_error')}: #{e}")
    end
    errors
  end

  def self.default_options
    {
      :csv => DulHydra.csv_options,
      :parse => {
        :include_empty_fields => false,
        :repeating_fields_separator => ";"
      }
    }
  end

  def profile_options
    if profile
      @profile_options ||= YAML::load(File.open(profile))
    else
      { :csv => {}, :parse => {}, :schema_map => {} }
    end
  end

  def effective_options
    csv = MetadataFile.default_options[:csv].merge(profile_options[:csv])
    parse = MetadataFile.default_options[:parse].merge(profile_options[:parse])
    { :csv => csv, :parse => parse, :schema_map => profile_options[:schema_map] }
  end

  def validate_controlled_values(header, idx)
    valid_values = case header.to_sym
                     when :admin_set
                       Ddr::Models::AdminSet.keys
                     when :research_help_contact
                       Ddr::Models::Contact.keys
                     when :license
                       Ddr::Models::License.keys
                   end
    as_csv_table.by_col.values_at(idx).each do |value|
      unless value.first.nil? || valid_values.include?(value.first)
        errors.add(:metadata, "#{I18n.t('batch.metadata_file.error.attribute_value')}: #{header} -> #{value.first}")
      end
    end
  end

  def valid_headers
    [ :pid, :model, :permanent_id, :is_governed_by ].concat(user_editable_fields)
  end

  def user_editable_fields
    Ddr::Datastreams::DescriptiveMetadataDatastream.term_names.concat(DulHydra.user_editable_admin_metadata_fields)
  end

  def controlled_value_headers
    [ :admin_set, :research_help_contact, :license ]
  end

  def model(row)
    row.headers.include?("model") ? row.field("model") : effective_options[:parse][:model]
  end

  def datastream(header)
    case
      when Ddr::Datastreams::DescriptiveMetadataDatastream.term_names.include?(header.to_sym)
        Ddr::Datastreams::DESC_METADATA
      when DulHydra.user_editable_admin_metadata_fields.include?(header.to_sym)
        Ddr::Datastreams::ADMIN_METADATA
    end
  end

  def procezz
    @batch = Ddr::Batch::Batch.create(
                :user => user,
                :name => I18n.t('batch.metadata_file.batch_name'),
                :description => metadata_file_name
                )
    # Create batch object for each row in file
    CSV.foreach(metadata.path, effective_options[:csv]) do |row|
      next if row.fields.compact.empty?    # skip empty rows
      obj = Ddr::Batch::UpdateBatchObject.new(:batch => @batch)
      obj.pid = row.field("pid") if row.headers.include?("pid")
      obj.model = row.field("model") if row.headers.include?("model")
      obj.identifier = row.field("local_id") if row.headers.include?("local_id")
      obj.save

      # Create CLEAR operation for each editable field in file
      editable_headers = row.headers.select { |hdr| user_editable_fields.include?(hdr.to_sym) }
      editable_headers.uniq.each do |header|
        att = Ddr::Batch::BatchObjectAttribute.new(
                  batch_object: obj,
                  datastream: datastream(header),
                  name: header,
                  operation: Ddr::Batch::BatchObjectAttribute::OPERATION_CLEAR
                  )
        obj.batch_object_attributes << att
      end

      # Create ADD operation for each editable field in file
      row.headers.each_with_index do |header, idx|
        if !row.field(header, idx).blank?
          parse_field(row.field(header, idx), header).each do |value|
            if editable_headers.include?(header)
              att = Ddr::Batch::BatchObjectAttribute.new(
                        batch_object: obj,
                        datastream: datastream(header),
                        name: header,
                        operation: Ddr::Batch::BatchObjectAttribute::OPERATION_ADD,
                        value: value,
                        value_type: Ddr::Batch::BatchObjectAttribute::VALUE_TYPE_STRING
                        )
              obj.batch_object_attributes << att
            end
          end
        end
      end

      # Legacy code that needs to be revisited
      # Is this part still needed and, if it is, should it be changed?
      # E.g., if we keep it, should it remain as is or be driven off local_id instead
      unless obj.pid.present?
        if obj.identifier.present?
          if collection_pid.present?
            @collection ||= ActiveFedora::Base.find(collection_pid, :cast => true)
          else
            @collection = nil
          end
          obj.pid = Ddr::Utils.pid_for_identifier(obj.identifier, {model: model(row), collection: @collection})
          obj.save
        end
      end
    end

    # Mark batch as ready for processing
    @batch.update_attributes(status: Ddr::Batch::Batch::STATUS_READY)
  end

  def downcase_repeatable_field_names
    effective_options[:parse][:repeatable_fields].map(&:downcase)
  end

  def parse_field(value, header)
    if downcase_repeatable_field_names.include?(header.downcase)
      value.split(effective_options[:parse][:repeating_fields_separator]).map(&:strip)
    else
      [ value ]
    end
  end

  def as_csv_table
    @csv_table ||= CSV.read(metadata.path, effective_options[:csv])
  end

end
