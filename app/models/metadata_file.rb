class MetadataFile < ActiveRecord::Base

  include ActiveModel::Validations

  belongs_to :user, :inverse_of => :metadata_files
  has_attached_file :metadata
  do_not_validate_attachment_file_type :metadata

  validates_presence_of :metadata, :profile

  def validate_data
    begin
      valid_headers = [ :pid, :model ].concat(Ddr::Datastreams::DescriptiveMetadataDatastream.term_names)
      as_csv_table.headers.each do |header|
        if effective_options[:schema_map].present?
          canonical_name = canonical_attribute_name(header)
          if canonical_name.present?
            unless valid_headers.include?(canonical_name.to_sym)
              errors.add(:metadata, "#{I18n.t('batch.metadata_file.error.mapped_attribute_name')}: #{header} => #{canonical_name}")
            end
          end
        else
          unless valid_headers.include?(header.to_sym)
            errors.add(:metadata, "#{I18n.t('batch.metadata_file.error.attribute_name')}: #{header}")
          end
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

  def self.downcase_schema_map_keys(schema_map)
    Hash[schema_map.map { |k, v| [k.downcase, v] } ]
  end

  def canonical_attribute_name(attribute_name)
    unless effective_options[:schema_map].present?
      return attribute_name if Ddr::Datastreams::DescriptiveMetadataDatastream.term_names.include?(attribute_name.to_sym)
    else
      @downcased_schema_map ||= MetadataFile.downcase_schema_map_keys(effective_options[:schema_map])
      return @downcased_schema_map[attribute_name.downcase] if @downcased_schema_map.has_key?(attribute_name.downcase)
    end
    return nil
  end

  def headers

  end

  def model(row)
    row.headers.include?("model") ? row.field("model") : effective_options[:parse][:model]
  end

  def procezz
    @batch = Ddr::Batch::Batch.create(
                :user => user,
                :name => I18n.t('batch.metadata_file.batch_name'),
                :description => metadata_file_name
                )
    CSV.foreach(metadata.path, effective_options[:csv]) do |row|
      obj = Ddr::Batch::UpdateBatchObject.new(:batch => @batch)
      obj.model = row.field("model") if row.headers.include?("model")
      obj.id = row.field("pid") if row.headers.include?("pid")
      att = Ddr::Batch::BatchObjectAttribute.new(
                batch_object: obj,
                datastream: Ddr::Datastreams::DESC_METADATA,
                operation: Ddr::Batch::BatchObjectAttribute::OPERATION_CLEAR_ALL)
      obj.batch_object_attributes << att
      obj.save
      row.headers.each_with_index do |header, idx|
        if effective_options[:parse][:include_empty_fields] || !row.field(header, idx).blank?
          if header.eql?(effective_options[:parse][:local_identifier])
            obj.update_attributes(:identifier => row.field(header, idx)) unless obj.identifier.present?
          end
          if canonical_attribute_name(header).present?
            parse_field(row.field(header, idx), header).each do |value|
              att = Ddr::Batch::BatchObjectAttribute.new(
                        batch_object: obj,
                        datastream: Ddr::Datastreams::DESC_METADATA,
                        name: canonical_attribute_name(header),
                        operation: Ddr::Batch::BatchObjectAttribute::OPERATION_ADD,
                        value: value,
                        value_type: Ddr::Batch::BatchObjectAttribute::VALUE_TYPE_STRING
                        )
              # puts canonical_attribute_name(header)
              # puts parse_field(row.field(header, idx), header)
              # puts att.inspect
              obj.batch_object_attributes << att
            end
          end
        end
      end
      unless obj.id.present?
        if obj.identifier.present?
          if collection_pid.present?
            @collection ||= ActiveFedora::Base.find(collection_pid, :cast => true)
          else
            @collection = nil
          end
          obj.id = Ddr::Utils.pid_for_identifier(obj.identifier, {model: model(row), collection: @collection})
          obj.save
        end
      end
    end
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
    CSV.read(metadata.path, effective_options[:csv])
  end

end
