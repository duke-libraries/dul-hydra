class MetadataFile < ActiveRecord::Base
  
  include ActiveModel::Validations

  serialize :options, Hash
  belongs_to :user, :inverse_of => :metadata_files
  has_attached_file :metadata
  attr_accessible :metadata, :metadata_file_name, :options
  validates_presence_of :metadata, :user
  
  def self.default_options
    { :column_separator => "\t",
      :quote_character => '`',
      :headers => true,
      :repeating_fields => [ "type", "subject" ],
      :repeating_fields_separator => ";",
      :include_empty_fields => false,
      :model => "Item",
      :attribute_map => self.downcase_attribute_map_keys(self.default_attribute_map)
    }
  end
  
  def csv_options
    { :col_sep => options[:column_separator],
      :quote_char => options[:quote_character],
      :headers => options[:headers]
    }
  end
  
  def self.downcase_attribute_map_keys(attribute_map)
    Hash[attribute_map.map { |k, v| [k.downcase, v] } ]
  end
  
  def canonical_attribute_name(attribute_name)
    return attribute_name if ActiveFedora::QualifiedDublinCoreDatastream::DCTERMS.include?(attribute_name.to_sym)
    return options[:attribute_map][attribute_name.downcase] if options[:attribute_map].has_key?(attribute_name.downcase)
    return nil
  end
  
  def model(row)
    row.headers.include?("model") ? row.field("model") : options[:model]
  end
  
  def procezz
    @batch = DulHydra::Batch::Models::Batch.create(
                :user => user,
                :name => I18n.t('batch.metadata_file.batch_name'),
                :description => metadata_file_name
                )
    CSV.foreach(metadata.path, csv_options) do |row|
      obj = DulHydra::Batch::Models::UpdateBatchObject.new(:batch => @batch)
      obj.model = row.field("model") if row.headers.include?("model")
      obj.pid = row.field("pid") if row.headers.include?("pid")
      obj.save
      ds = ActiveFedora::QualifiedDublinCoreDatastream.new
      row.headers.each do |header|
        if !row.field(header).blank?  # for now, assume we're not including empty fields
          if canonical_attribute_name(header).present?
            if canonical_attribute_name(header).eql?("identifier")
              obj.update_attributes(:identifier => row.field(header)) unless obj.identifier.present?
            end
            ds.send("#{canonical_attribute_name(header).to_sym}=", parse_field(row.field(header), header))
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
        obj.pid = determine_pid_from_identifier(obj.identifier, model(row))
        obj.save
      end
    end
  end
  
  def parse_field(value, header)
    if options[:repeating_fields].include?(header)
      value.split(options[:repeating_fields_separator]).map(&:strip)
    else
      value
    end
  end
  
  def determine_pid_from_identifier(identifier, model)
    objs = []
    ActiveFedora::Base.find_each( { DulHydra::IndexFields::IDENTIFIER => identifier }, { :cast => true } ) { |o| objs << o }
    case objs.size
    when 0
      pid = nil
    when 1
      pid = objs.first.pid
    else
      if model.present?
        model_matches = 0
        objs.each do |obj|
          if obj.class.eql?(model.constantize)
            pid = obj.pid
            model_matches += 1
          end
        end
        if model_matches > 1
          raise DulHydra::Error, I18n.t('dul_hydra.errors.multiple_object_matches', :criteria => "model #{model} identifier #{identifier}")
        end
      else
        raise DulHydra::Error, I18n.t('dul_hydra.errors.multiple_object_matches', :criteria => "identifer #{identifier}")
      end
    end
    return pid
  end
  
  def self.default_attribute_map
    {
      "Title" => "title",
      "Subject-Name" => "subject",
      "Subject-Topic" => "subject",
      "Description" => "description",
      "Creator" => "creator",
      "Date" => "date",
      "Type-DCMI" => "type",
      "Type-AAT" => "type",
      "Type-Genre" => "type",
      "Identifier-DukeID" => "identifier",
      "Print Number" => "identifier",
      "Identifier-Other" => "identifier",
      "Source" => "source",
      "Digital Collection" => "isPartOf",
      "Language" => "language",
      "Rights" => "rights",
      "Extent" => "extent",
      "Spatial" => "spatial",
      "Series" => "isPartOf",
      "Subseries" => "isPartOf"
    }    
  end

end