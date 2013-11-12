class IngestFolder < ActiveRecord::Base
  
  attr_accessible :admin_policy_pid, :collection_pid, :model, :file_creator, :base_path, :sub_path,
                  :checksum_file, :checksum_type
  belongs_to :user, :inverse_of => :ingest_folders

  CONFIG_FILE = File.join(Rails.root, 'config', 'folder_ingest.yml')
  
  DEFAULT_INCLUDED_FILE_EXTENSIONS = ['.pdf', '.tif', '.tiff']
  
  def self.load_configuration
    @@configuration ||= YAML::load(File.read(CONFIG_FILE)).with_indifferent_access
  end
  
  def self.default_file_model
    self.load_configuration.fetch(:config).fetch(:file_model)
  end
  
  def self.file_creators
    self.load_configuration.fetch(:config).fetch(:file_creators)
  end
  
  def self.permitted_folders(user)
    user ||= User.new
    self.load_configuration.fetch(:files).fetch(:permissions).fetch(user.user_key, [])
  end
  
  def mount_point
    base_key = base_path.split(File::Separator).first
    IngestFolder.load_configuration.fetch(:files).fetch(:mount_points).fetch(base_key, nil)
  end

  def full_path
    path = File.join(mount_point || '', abbreviated_path)
    path.eql?(File::SEPARATOR) ? nil : path
  end
  
  def abbreviated_path
    File.join(base_path || '', sub_path || '')
  end
  
  def scan
    @included = 0
    @excluded = []
    scan_files(full_path, false)
    return @included, @excluded
  end
  
  def procezz
    @batch = DulHydra::Batch::Models::Batch.create(:user => user)
    @checksum_hash = checksums if checksum_file
    puts @checksum_hash
    scan_files(full_path, true)
  end
  
  def file_checksum(file_entry)
    @checksum_hash.fetch(checksum_hash_key(file_entry))
  end
  
  def checksums
    checksum_file_location = File.join(full_path, checksum_file)
    checksum_file_path = File.dirname(checksum_file_location)
    @checksum_file_directory = checksum_file_path.split(File::SEPARATOR).last
    checksum_hash = {}
    begin
      File.open(checksum_file_location, 'r') do |file|
        file.each_line do |line|
          sum, path = line.split
          checksum_hash[checksum_hash_key(path)] = sum
        end
      end
    end
    checksum_hash
  end
  
  def checksum_hash_key(file_path)
    normalized_path = file_path.gsub('\\', File::SEPARATOR)
    idx = normalized_path.index(@checksum_file_directory)
    len = normalized_path.length
    key = normalized_path[idx, len]
  end

  def scan_files(dirpath, create_batch_objects)
    Dir.foreach(dirpath) do |entry|
      unless [".", ".."].include?(entry)
        if File.directory?(File.join(dirpath, entry))
          scan_files(File.join(dirpath, entry), create_batch_objects)
        else
          if DEFAULT_INCLUDED_FILE_EXTENSIONS.include?(File.extname(entry))
            @included += 1 if !create_batch_objects
            create_batch_object_for_file(dirpath, entry) if create_batch_objects
          else
            exc = File.join(dirpath, entry)
            exc.slice! full_path
            exc.slice!(0) if exc.starts_with?(File::SEPARATOR)
            @excluded << exc if !create_batch_objects
          end
        end
      end
    end
  end
  
  def create_batch_object_for_file(dirpath, file_entry)
    obj = DulHydra::Batch::Models::IngestBatchObject.create(
            :batch => @batch,
            :identifier => extract_identifier_from_filename(file_entry),
            :model => IngestFolder.default_file_model
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
            DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_FILENAME,
            file_checksum(File.join(dirpath, file_entry)),
            checksum_type
            )
    add_relationship(
            obj,
            DulHydra::Batch::Models::BatchObjectRelationship::RELATIONSHIP_ADMIN_POLICY,
            admin_policy_pid
            ) if admin_policy_pid
    obj.save
  end
  
  def add_datastream(batch_object, datastream, payload, payload_type, checksum=nil, checksum_type=nil)
    DulHydra::Batch::Models::BatchObjectDatastream.create(
      :batch_object => batch_object,
      :name => datastream,
      :operation => DulHydra::Batch::Models::BatchObjectDatastream::OPERATION_ADD,
      :payload => payload,
      :payload_type => payload_type,
      :checksum => checksum,
      :checksum_type => checksum_type
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
    component = IngestFolder.default_file_model.constantize.new
    component.identifier = identifier
    component.source = file_entry
    component.creator = "DPC"
    component.descMetadata.content
  end
  
  def extract_identifier_from_filename(file_entry)
    File.basename(file_entry, File.extname(file_entry))
  end  
  
end
