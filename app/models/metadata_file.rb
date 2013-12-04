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
      :attribute_map => self.default_attribute_map
    }
  end
  
  def csv_options
    { :col_sep => options[:column_separator],
      :quote_char => options[:quote_character],
      :headers => options[:headers]
    }
  end
  
  def canonical_attribute_name(attribute_name)
    return attribute_name if ActiveFedora::QualifiedDublinCoreDatastream::DCTERMS.include?(attribute_name.to_sym)
    return options[:attribute_map][attribute_name] if options[:attribute_map].has_key?(attribute_name)
    return nil
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
      obj.model = options[:model] unless obj.model.present? 
      obj.pid = row.field("pid") if row.headers.include?("pid")
      obj.save
      ds = ActiveFedora::QualifiedDublinCoreDatastream.new
      row.headers.each do |header|
        if !row.field(header).blank?  # for now, assume we're not including empty fields
          if canonical_attribute_name(header).present?
            if canonical_attribute_name(header).eql?("identifier")
              obj.update_attributes(:identifier => row.field(header))
            end
            ds.send("#{canonical_attribute_name(header).to_sym}=", row.field(header))
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
        obj.pid = determine_pid_from_identifier(obj.identifier, obj.model)
        obj.save
      end
    end
  end
  
  def determine_pid_from_identifier(identifier, model)
    objs = []
    ActiveFedora::Base.find_each( { DulHydra::IndexFields::IDENTIFIER => identifier }, { :cast => true } ) { |o| objs << o }
    case objs.size
    when 0
      return nil
    when 1
      return objs.first.pid
    else
      if model.present?
        objs.each { |obj| return obj.pid if obj.class.eql?(model.constantize) }
      else
        raise DulHydra::Error, I18n.t('dul_hydra.errors.multiple_object_matches', :criteria => "identifer #{identifier}")
      end
    end
  end
  
  def self.default_attribute_map
    {
      "Title" => "title",
      "Subject-Name" => "subject",
      "Subject-Topic" => "subject",
      "Identifier-DukeID" => "identifier"
    }    
  end

end