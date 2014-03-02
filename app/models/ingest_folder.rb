class IngestFolder < ActiveRecord::Base
  
  include ActiveModel::Validations
  
  after_initialize :init
  
  belongs_to :user, :inverse_of => :ingest_folders
  
  validates_presence_of :collection_pid, :sub_path
  validate :path_must_be_permitted
  validate :path_must_be_readable
  
  CONFIG_FILE = File.join(Rails.root, 'config', 'folder_ingest.yml')
  
  DEFAULT_INCLUDED_FILE_EXTENSIONS = ['.pdf', '.tif', '.tiff']
  
  ScanResults = Struct.new(:total_count, :file_count, :parent_count, :target_count, :excluded_files)
  
  def init
    if self.new_record?
      self.checksum_type = IngestFolder.default_checksum_type
    end
  end
    
  def self.load_configuration
    @@configuration ||= YAML::load(File.read(CONFIG_FILE)).with_indifferent_access
  end
  
  def self.default_checksum_file_location
    self.load_configuration.fetch(:config).fetch(:checksum_file).fetch(:location)
  end
  
  def self.default_checksum_type
    self.load_configuration.fetch(:config).fetch(:checksum_file).fetch(:type)
  end
  
  def self.default_file_model
    self.load_configuration.fetch(:config).fetch(:file_model)
  end
  
  def self.default_target_model
    self.load_configuration.fetch(:config).fetch(:target_model)
  end
  
  def self.default_target_folder
    self.load_configuration.fetch(:config).fetch(:target_folder)
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
  
  def full_checksum_path
    path = IngestFolder.default_checksum_file_location
    path.eql?(File::SEPARATOR) ? nil : path
  end
  
  def checksum_file_location
    case
    when checksum_file.blank?
      path_parts = sub_path.split(File::SEPARATOR).reject { |p| p.empty? }
      File.join(full_checksum_path, "#{path_parts.first}.txt")
    when checksum_file.start_with?(File::SEPARATOR)
      checksum_file
    else
      File.join(full_checksum_path, checksum_file)
    end
  end
  
  def collection
    @collection ||= Collection.find(collection_pid) if collection_pid
  end
  
  def collection_admin_policy
    collection.admin_policy
  end
  
  def collection_permissions_attributes
    collection.permissions.collect { |p| p.to_hash }
  end
  
  def scan
    @parent_hash = {} if add_parents
    @total_count = 0
    @file_count = 0
    @parent_count = 0
    @target_count = 0
    @excluded_files = []
    scan_files(full_path, false)
    return ScanResults.new(@total_count, @file_count, @parent_count, @target_count, @excluded_files)
  end
  
  def procezz
    @batch = DulHydra::Batch::Models::Batch.create(
                :user => user,
                :name => I18n.t('batch.ingest_folder.batch_name'),
                :description => abbreviated_path
                )
    @total_count = 0
    @file_count = 0
    @parent_count = 0
    @target_count = 0
    @excluded_files = []
    @parent_hash = {} if add_parents
    @checksum_hash = checksums if checksum_file.present?
    if collection_admin_policy.blank? && collection_permissions_attributes.present?
      temp_surrogate = DulHydra::Base.new
      temp_surrogate.permissions_attributes = collection_permissions_attributes
      @rights_metadata_content = temp_surrogate.rightsMetadata.content
    end
    scan_files(full_path, true)
  end
  
  def file_checksum(file_entry)
    @checksum_hash.fetch(checksum_hash_key(file_entry))
  end
  
  def checksums
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
    file_path
  end

  def scan_files(dirpath, create_batch_objects)
    enumerator = Dir.foreach(dirpath)
    enumerator.each do |entry|
      unless [".", ".."].include?(entry)
        file_loc = File.join(dirpath, entry)
        if File.directory?(file_loc)
          scan_files(file_loc, create_batch_objects)
        else
          @total_count += 1
          if DEFAULT_INCLUDED_FILE_EXTENSIONS.include?(File.extname(entry))
            case target?(dirpath)
            when true
              @target_count += 1
            else
              @file_count += 1
              if add_parents && !target?(dirpath)
                parent_id = parent_identifier(extract_identifier_from_filename(entry))
                unless @parent_hash.has_key?(parent_id)
                  @parent_count += 1
                  @parent_hash[parent_id] = nil
                end
              end
            end
            create_batch_object_for_file(dirpath, entry) if create_batch_objects
          else
            exc = file_loc
            exc.slice! full_path
            exc.slice!(0) if exc.starts_with?(File::SEPARATOR)
            @excluded_files << exc if !create_batch_objects
          end
        end
      end
    end
  end
  
  def create_batch_object_for_parent(parent_identifier)
    parent_model = DulHydra::Utils.reflection_object_class(DulHydra::Utils.relationship_object_reflection(model, "parent")).name
    parent_pid = ActiveFedora::Base.connection_for_pid('0').mint
    obj = DulHydra::Batch::Models::IngestBatchObject.create(
            :batch => @batch,
            :identifier => parent_identifier,
            :model => parent_model,
            :pid => parent_pid
            )
    add_datastream(
            obj,
            DulHydra::Datastreams::DESC_METADATA,
            desc_metadata(parent_identifier),
            DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_BYTES
            )
    add_datastream(
            obj,
            DulHydra::Datastreams::RIGHTS_METADATA,
            @rights_metadata_content,
            DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_BYTES            
            ) if @rights_metadata_content
    add_relationship(
            obj,
            DulHydra::Batch::Models::BatchObjectRelationship::RELATIONSHIP_ADMIN_POLICY,
            collection_admin_policy.pid
            ) if collection_admin_policy
    add_relationship(
            obj,
            DulHydra::Batch::Models::BatchObjectRelationship::RELATIONSHIP_PARENT,
            collection_pid
            ) if collection_pid
    parent_pid
  end
  
  def parent_identifier(child_identifier)
    case parent_id_length
    when nil then child_identifier
    when 0 then child_identifier
    else child_identifier[0, parent_id_length]
    end
  end
  
  def target?(dirpath)
    dirpath.index(IngestFolder.default_target_folder).present?
  end
  
  def create_batch_object_for_file(dirpath, file_entry)
    file_identifier = extract_identifier_from_filename(file_entry)
    file_model = target?(dirpath) ? IngestFolder.default_target_model : model
    if add_parents && !target?(dirpath)
      parent_id = parent_identifier(file_identifier)
      parent_pid = @parent_hash.fetch(parent_id, nil)
      if parent_pid.blank?
        parent_pid = create_batch_object_for_parent(parent_id)
        @parent_hash[parent_id] = parent_pid
      end
    end
    obj = DulHydra::Batch::Models::IngestBatchObject.create(
            :batch => @batch,
            :identifier => file_identifier,
            :model => file_model
            )
    add_datastream(
            obj,
            DulHydra::Datastreams::DESC_METADATA,
            desc_metadata(file_identifier, file_entry, file_creator),
            DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_BYTES
            )
    add_datastream(
            obj,
            DulHydra::Datastreams::CONTENT,
            File.join(dirpath, file_entry),
            DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_FILENAME,
            checksum_file.present? ? file_checksum(File.join(dirpath, file_entry)) : nil,
            checksum_file.present? ? checksum_type : nil
            )
    add_datastream(
            obj,
            DulHydra::Datastreams::RIGHTS_METADATA,
            @rights_metadata_content,
            DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_BYTES            
            ) if @rights_metadata_content
    add_relationship(
            obj,
            DulHydra::Batch::Models::BatchObjectRelationship::RELATIONSHIP_ADMIN_POLICY,
            collection_admin_policy.pid
            ) if collection_admin_policy
    add_relationship(
            obj,
            DulHydra::Batch::Models::BatchObjectRelationship::RELATIONSHIP_PARENT,
            parent_pid
            ) if add_parents && parent_pid
    add_relationship(
            obj,
            DulHydra::Batch::Models::BatchObjectRelationship::RELATIONSHIP_COLLECTION,
            collection_pid
            ) if target?(dirpath) && collection_pid
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
  
  def desc_metadata(identifier, source=nil, creator=nil)
    base = DulHydra::Base.new
    base.identifier = identifier if identifier.present?
    base.source = source if source.present?
    base.creator = creator if creator.present?
    base.descMetadata.content
  end
  
  def extract_identifier_from_filename(file_entry)
    File.basename(file_entry, File.extname(file_entry))
  end  

  def path_must_be_permitted
    errors.add(:base_path, I18n.t('batch.ingest_folder.base_path.forbidden', :path => base_path)) unless IngestFolder.permitted_folders(user).include?(base_path)
  end

  def path_must_be_readable
    errors.add(:sub_path, I18n.t('batch.ingest_folder.not_readable', :path => sub_path)) unless File.readable?(full_path)
    if checksum_file.present?
      errors.add(:checksum_file, I18n.t('batch.ingest_folder.not_readable', :path => checksum_file_location)) unless File.readable?(checksum_file_location)
    end
  end
  
end
