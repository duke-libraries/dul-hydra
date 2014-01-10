class MetadataFile < ActiveRecord::Base
  
  include ActiveModel::Validations

  belongs_to :user, :inverse_of => :metadata_files
  has_attached_file :metadata
  
  validates_presence_of :metadata, :profile
  
  def validate_parseability
    begin
      CSV.read(metadata.path, effective_options[:csv])
    rescue CSV::MalformedCSVError
      errors.add(:metadata, "Parse error")
    end
    errors
  end
  
  def self.default_options
    {
      :csv => {
        :col_sep => ",",
        :quote_char => '"',
        :headers => true
      },
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
      return attribute_name if ActiveFedora::QualifiedDublinCoreDatastream::DCTERMS.include?(attribute_name.to_sym)
    else
      @downcased_schema_map ||= MetadataFile.downcase_schema_map_keys(effective_options[:schema_map])
      return @downcased_schema_map[attribute_name.downcase] if @downcased_schema_map.has_key?(attribute_name.downcase)
    end
    return nil
  end
  
  def model(row)
    row.headers.include?("model") ? row.field("model") : effective_options[:parse][:model]
  end
  
  def procezz
    @batch = DulHydra::Batch::Models::Batch.create(
                :user => user,
                :name => I18n.t('batch.metadata_file.batch_name'),
                :description => metadata_file_name
                )
    CSV.foreach(metadata.path, effective_options[:csv]) do |row|
      obj = DulHydra::Batch::Models::UpdateBatchObject.new(:batch => @batch)
      obj.model = row.field("model") if row.headers.include?("model")
      obj.pid = row.field("pid") if row.headers.include?("pid")
      obj.save
      ds = ActiveFedora::QualifiedDublinCoreDatastream.new
      row.headers.each_with_index do |header, idx|
        if effective_options[:parse][:include_empty_fields] || !row.field(header, idx).blank?
          if header.eql?(effective_options[:parse][:local_identifier])
            obj.update_attributes(:identifier => row.field(header, idx)) unless obj.identifier.present?
          end
          if canonical_attribute_name(header).present?
            value = ds.send(canonical_attribute_name(header))
            value += parse_field(row.field(header, idx), header)
            ds.send("#{canonical_attribute_name(header)}=", value)
          end
        end
      end
      obj_ds = DulHydra::Batch::Models::BatchObjectDatastream.create(
                :batch_object => obj,
                :name => DulHydra::Datastreams::DESC_METADATA,
                :operation => DulHydra::Batch::Models::BatchObjectDatastream::OPERATION_ADDUPDATE,
                :payload => ds.content,
                :payload_type => DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_BYTES
                )
      unless obj.pid.present?
        if obj.identifier.present?
          if collection_pid.present?
            @collection ||= ActiveFedora::Base.find(collection_pid, :cast => true)
          else
            @collection = nil
          end
          obj.pid = determine_pid_from_identifier(obj.identifier, model(row), @collection)
          obj.save
        end
      end
    end
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
  
  def determine_pid_from_identifier(identifier, model, collection)
    objs = []
    ActiveFedora::Base.find_each( { DulHydra::IndexFields::IDENTIFIER => identifier }, { :cast => true } ) { |o| objs << o }
    pids = []
    objs.each { |obj| pids << obj.pid }
    if model.present?
      objs.each { |obj| pids.delete(obj.pid) unless obj.is_a?(model.constantize) }
    end
    if collection.present?
      objs.each { |obj| pids.delete(obj.pid) unless obj == collection || collection.children.include?(obj) }
    end
    pid = case pids.size
    when 0
      nil
    when 1
      pids.first
    else
      raise DulHydra::Error, I18n.t('dul_hydra.errors.multiple_object_matches', :criteria => "identifier #{identifier}")
    end
    return pid
  end

end