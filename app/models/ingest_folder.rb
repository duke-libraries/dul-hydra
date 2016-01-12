class IngestFolder < ActiveRecord::Base

  include ActiveModel::Validations

  belongs_to :user, inverse_of: :ingest_folders

  validates_presence_of :collection_pid, :sub_path
  validate :path_must_be_permitted
  validate :path_must_be_readable

  CONFIG_FILE = File.join(Rails.root, 'config', 'folder_ingest.yml')

  DEFAULT_INCLUDED_FILE_EXTENSIONS = ['.pdf', '.tif', '.tiff']

  ScanResults = Struct.new(:total_count, :file_count, :parent_count, :target_count, :excluded_files)

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

  def self.permitted_folders(user)
    user ||= User.new
    self.load_configuration.fetch(:files).fetch(:permissions).fetch(user.user_key, [])
  end

  def included_extensions
    IngestFolder.load_configuration.fetch(:files).fetch(:included_extensions, DEFAULT_INCLUDED_FILE_EXTENSIONS)
  end

  def mount_point
    IngestFolder.load_configuration.fetch(:files).fetch(:mount_points).fetch(mount_point_base_key, nil)
  end

  def mount_point_base_key
    base_path.split(File::Separator).first
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
      ctype = checksum_type.gsub("-","").downcase
      File.join(full_checksum_path, "#{path_parts.first}-#{mount_point_base_key}-#{ctype}.txt")
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
    @checksum_hash = checksums if checksum_file.present?
    @total_count = 0
    @file_count = 0
    @parent_count = 0
    @target_count = 0
    @excluded_files = []
    scan_files(full_path, false)
    return ScanResults.new(@total_count, @file_count, @parent_count, @target_count, @excluded_files)
  end

  def procezz
    @batch = Ddr::Batch::Batch.create(
                user: user,
                name: I18n.t('batch.ingest_folder.batch_name'),
                description: abbreviated_path
                )
    @total_count = 0
    @file_count = 0
    @parent_count = 0
    @target_count = 0
    @excluded_files = []
    @parent_hash = {} if add_parents
    @checksum_hash = checksums if checksum_file.present?
    scan_files(full_path, true)
    @batch.update_attributes(status: Ddr::Batch::Batch::STATUS_READY)
  end

  def file_checksum(file_entry)
    @checksum_hash.fetch(checksum_hash_key(file_entry), nil)
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
          if included_extensions.include?(File.extname(entry))
            case target?(dirpath)
            when true
              @target_count += 1
            else
              @file_count += 1
              if add_parents && !target?(dirpath)
                parent_loc_id = parent_local_id(extract_identifier_from_filename(entry))
                unless @parent_hash.has_key?(parent_loc_id)
                  @parent_count += 1
                  @parent_hash[parent_loc_id] = nil
                end
              end
            end
            if checksum_file.present? && file_checksum(File.join(dirpath, entry)).blank?
              errors.add(:base, I18n.t('batch.ingest_folder.checksum_missing', entry: File.join(dirpath, entry)))
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

  def create_batch_object_for_parent(parent_loc_id)
    parent_model = Ddr::Utils.reflection_object_class(Ddr::Utils.relationship_object_reflection(model, "parent")).name
    policy_pid = collection_admin_policy ? collection_admin_policy.id : collection_pid
    obj = Ddr::Batch::IngestBatchObject.create(
            batch: @batch,
            identifier: parent_loc_id,
            model: parent_model
            )
    Ddr::Batch::BatchObjectAttribute.create(
            batch_object: obj,
            datastream: 'adminMetadata',
            name: 'local_id',
            operation: Ddr::Batch::BatchObjectAttribute::OPERATION_ADD,
            value: parent_loc_id,
            value_type: Ddr::Batch::BatchObjectAttribute::VALUE_TYPE_STRING
            )
    Ddr::Batch::BatchObjectRelationship.create(
            batch_object: obj,
            name: Ddr::Batch::BatchObjectRelationship::RELATIONSHIP_ADMIN_POLICY,
            object: policy_pid,
            object_type: Ddr::Batch::BatchObjectRelationship::OBJECT_TYPE_REPO_ID,
            operation: Ddr::Batch::BatchObjectRelationship::OPERATION_ADD
            )
    Ddr::Batch::BatchObjectRelationship.create(
            batch_object: obj,
            name: Ddr::Batch::BatchObjectRelationship::RELATIONSHIP_PARENT,
            object: collection_pid,
            object_type: Ddr::Batch::BatchObjectRelationship::OBJECT_TYPE_REPO_ID,
            operation: Ddr::Batch::BatchObjectRelationship::OPERATION_ADD
            ) if collection_pid
    obj.id
  end

  def parent_local_id(child_local_id)
    case parent_id_length
    when nil then child_local_id
    when 0 then child_local_id
    else child_local_id[0, parent_id_length]
    end
  end

  def target?(dirpath)
    dirpath.index(IngestFolder.default_target_folder).present?
  end

  def create_batch_object_for_file(dirpath, file_entry)
    file_identifier = extract_identifier_from_filename(file_entry)
    file_model = target?(dirpath) ? IngestFolder.default_target_model : model
    if add_parents && !target?(dirpath)
      parent_loc_id = parent_local_id(file_identifier)
      parent_rec_id = @parent_hash.fetch(parent_loc_id, nil)
      if parent_rec_id.blank?
        parent_rec_id = create_batch_object_for_parent(parent_loc_id)
        @parent_hash[parent_loc_id] = parent_rec_id
      end
    end
    policy_pid = collection_admin_policy ? collection_admin_policy.id : collection_pid
    obj = Ddr::Batch::IngestBatchObject.create(
            batch: @batch,
            identifier: file_identifier,
            model: file_model
            )
    Ddr::Batch::BatchObjectAttribute.create(
            batch_object: obj,
            datastream: 'adminMetadata',
            name: 'local_id',
            operation: Ddr::Batch::BatchObjectAttribute::OPERATION_ADD,
            value: file_identifier,
            value_type: Ddr::Batch::BatchObjectAttribute::VALUE_TYPE_STRING
            )
    Ddr::Batch::BatchObjectDatastream.create(
            batch_object: obj,
            name: Ddr::Datastreams::CONTENT,
            operation: Ddr::Batch::BatchObjectDatastream::OPERATION_ADD,
            payload: File.join(dirpath, file_entry),
            payload_type: Ddr::Batch::BatchObjectDatastream::PAYLOAD_TYPE_FILENAME,
            checksum: checksum_file.present? ? file_checksum(File.join(dirpath, file_entry)) : nil,
            checksum_type: checksum_file.present? ? checksum_type : nil
            )
    Ddr::Batch::BatchObjectRelationship.create(
            batch_object: obj,
            name: Ddr::Batch::BatchObjectRelationship::RELATIONSHIP_ADMIN_POLICY,
            object: policy_pid,
            object_type: Ddr::Batch::BatchObjectRelationship::OBJECT_TYPE_REPO_ID,
            operation: Ddr::Batch::BatchObjectRelationship::OPERATION_ADD
            )
    Ddr::Batch::BatchObjectRelationship.create(
            batch_object: obj,
            name: Ddr::Batch::BatchObjectRelationship::RELATIONSHIP_PARENT,
            object: parent_rec_id,
            object_type: Ddr::Batch::BatchObjectRelationship::OBJECT_TYPE_REC_ID,
            operation: Ddr::Batch::BatchObjectRelationship::OPERATION_ADD
            ) if add_parents && parent_rec_id
    Ddr::Batch::BatchObjectRelationship.create(
            batch_object: obj,
            name: Ddr::Batch::BatchObjectRelationship::RELATIONSHIP_COLLECTION,
            object: collection_pid,
            object_type: Ddr::Batch::BatchObjectRelationship::OBJECT_TYPE_REPO_ID,
            operation: Ddr::Batch::BatchObjectRelationship::OPERATION_ADD
            ) if target?(dirpath) && collection_pid
    obj.save
  end

  def extract_identifier_from_filename(file_entry)
    File.basename(file_entry, File.extname(file_entry))
  end

  def path_must_be_permitted
    errors.add(:base_path, I18n.t('batch.ingest_folder.base_path.forbidden', path: base_path)) unless IngestFolder.permitted_folders(user).include?(base_path)
  end

  def path_must_be_readable
    errors.add(:sub_path, I18n.t('batch.ingest_folder.not_readable', path: sub_path)) unless File.readable?(full_path)
    if checksum_file.present?
      errors.add(:checksum_file, I18n.t('batch.ingest_folder.not_readable', path: checksum_file_location)) unless File.readable?(checksum_file_location)
    end
  end

end
