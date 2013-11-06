class IngestFolder < ActiveRecord::Base
  
  attr_accessible :dirpath, :username, :admin_policy_pid, :collection_pid, :model, :file_creator
  
  DEFAULT_INCLUDED_FILE_EXTENSIONS = ['.tif', '.tiff']
  DEFAULT_FILE_MODEL = "Component"
  
  FILE_CREATORS = { "DPC" => "Digital Production Center" }
  
  def scan
    @included = 0
    @excluded = []
    scan_files(dirpath, false)
    return [@included, @excluded]
  end
  
  def procezz
    @batch = DulHydra::Batch::Models::Batch.create(:user => User.find_by_username(username))
    scan_files(dirpath, true)
  end
  
  def scan_files(dirpath, create_batch_objects)
    Dir.foreach(dirpath) do |entry|
      unless [".", ".."].include?(entry)
        if File.directory?(File.join(dirpath, entry))
          scan_files(File.join(dirpath, entry))
        else
          if DEFAULT_INCLUDED_FILE_EXTENSIONS.include?(File.extname(entry))
            @included += 1 if !create_batch_objects
            create_batch_object_for_file(dirpath, entry) if create_batch_objects
          else
            @excluded << File.join(dirpath, entry) if !create_batch_objects
          end
        end
      end
    end
  end
  
  def create_batch_object_for_file(dirpath, file_entry)
    obj = DulHydra::Batch::Models::IngestBatchObject.create(
            :batch => @batch,
            :identifier => extract_identifier_from_filename(file_entry),
            :model => DEFAULT_FILE_MODEL
            )
    add_datastream(
            obj,
            DulHydra::Datastreams::DESC_METADATA,
            desc_metadata_for_file(file_entry),
            DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_BYTES
            )
    add_datastream(
            obj,
            DulHydra::Datastreams::CONTENT,
            File.join(dirpath, file_entry),
            DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_FILENAME
            )
    add_relationship(
            obj,
            DulHydra::Batch::Models::BatchObjectRelationship::RELATIONSHIP_ADMIN_POLICY,
            admin_policy_pid
            ) if admin_policy_pid
    obj.save
  end
  
  def add_datastream(batch_object, datastream, payload, payload_type)
    DulHydra::Batch::Models::BatchObjectDatastream.create(
      :batch_object => batch_object,
      :name => datastream,
      :operation => DulHydra::Batch::Models::BatchObjectDatastream::OPERATION_ADD,
      :payload => payload,
      :payload_type => payload_type
      )    
  end
  
  def add_relationship(batch_object, relationship, pid)
    DulHydra::Batch::Models::BatchObjectRelationship.create(
      :batch_object => batch_object,
      :name => relationship,
      :object => pid,
      :object_type => DulHydra::Batch::Models::BatchObjectRelationship::OBJECT_TYPE_PID,
      :operation => DulHydra::Batch::Models::BatchObjectRelationship::OPERATION_ADD
    )    
  end
  
  def desc_metadata_for_file(file_entry)
    identifier = extract_identifier_from_filename(file_entry)
    component = Component.new
    component.identifier = identifier
    component.source = file_entry
    component.creator = "DPC"
    component.descMetadata.content
  end
  
  def extract_identifier_from_filename(file_entry)
    File.basename(file_entry, File.extname(file_entry))
  end
  
end
