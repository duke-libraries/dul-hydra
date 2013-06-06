class Manifest
  
  AUTOIDLENGTH = 'autoidlength'
  BASEPATH = 'basepath'
  BATCH = 'batch'
  BATCHID = 'batchid'
  CHECKSUM = 'checksum'
  DATASTREAMS = 'datastreams'
  DESCRIPTION = 'description'
  EXTENSION = 'extension'
  ID = 'id'
  IDENTIFIER_ELEMENT = 'identifier_element'
  LABEL = 'label'
  LOCATION = 'location'
  MODEL = 'model'
  NAME = 'name'
  NODE_XPATH = 'node_xpath'
  OBJECTS = 'objects'
  PID = 'pid'
  SOURCE = 'source'
  TYPE = 'type'
  TYPE_XPATH = 'type_xpath'
  USER_EMAIL = 'user_email'
  VALUE_XPATH = 'value_xpath'  

  MANIFEST_KEYS = [ BASEPATH, BATCH, CHECKSUM, DATASTREAMS, DESCRIPTION, LABEL, MODEL, NAME, OBJECTS, BatchObjectDatastream::DATASTREAMS, BatchObjectRelationship::RELATIONSHIPS ].flatten
  BATCH_KEYS = [ DESCRIPTION, ID, NAME, USER_EMAIL ]
  MANIFEST_CHECKSUM_KEYS = [ LOCATION, SOURCE, TYPE, NODE_XPATH, IDENTIFIER_ELEMENT, TYPE_XPATH, VALUE_XPATH ]
  MANIFEST_DATASTREAM_KEYS = [ EXTENSION, LOCATION ]
  MANIFEST_RELATIONSHIP_KEYS = [ AUTOIDLENGTH, BATCHID, ID, PID ]
  
  def initialize(manifest_filepath=nil)
    if manifest_filepath
      begin
        @manifest_hash = File.open(manifest_filepath) { |f| YAML::load(f) }
      rescue
        raise ArgumentError, I18n.t('batch.manifest.errors.file_error', :file => manifest_filepath)
      end
    else
      @manifest_hash = {}
    end
  end
  
  def validate
    errors = []
    errors += validate_model if model
    errors += validate_keys
    errors += validate_datastream_list if datastreams
    BatchObjectDatastream::DATASTREAMS.each do |datastream|
      if manifest_hash[datastream] && manifest_hash[datastream][LOCATION]
        errors += validate_datastream_filepath(datastream)
      end
    end
    errors += validate_checksum_file if checksums?
    errors += validate_checksum_type if checksum_type?
    BatchObjectRelationship::RELATIONSHIPS.each do |relationship|
      if has_relationship?(relationship)
        errors += validate_relationship(relationship)
      end
    end
    return errors
  end

  def validate_keys
    errs = []
    manifest_hash.keys.each do |key|
      errs << I18n.t('batch.manifest.errors.invalid_key', :key => key) unless MANIFEST_KEYS.include?(key)
      case 
      when key.eql?(BATCH)
        manifest_hash[BATCH].keys.each do |subkey|
          errs << I18n.t('batch.manifest.errors.invalid_subkey', :key => BATCH, :subkey => subkey) unless BATCH_KEYS.include?(subkey)
        end
      when key.eql?(CHECKSUM)
        manifest_hash[CHECKSUM].keys.each do |subkey|
          errs << I18n.t('batch.manifest.errors.invalid_subkey', :key => CHECKSUM, :subkey => subkey) unless MANIFEST_CHECKSUM_KEYS.include?(subkey)
        end
      when BatchObjectDatastream::DATASTREAMS.include?(key)
        manifest_hash[key].keys.each do |subkey|
          errs << I18n.t('batch.manifest.errors.invalid_subkey', :key => key, :subkey => subkey) unless MANIFEST_DATASTREAM_KEYS.include?(subkey)
        end
      when BatchObjectRelationship::RELATIONSHIPS.include?(key)
        if manifest_hash[key].is_a?(Hash)
          manifest_hash[key].keys.each do |subkey|
            errs << I18n.t('batch.manifest.errors.invalid_subkey', :key => key, :subkey => subkey) unless MANIFEST_RELATIONSHIP_KEYS.include?(subkey)
          end
        end
      end
    end
    return errs
  end
  
  def validate_relationship(relationship)
    errs = []
    pid = relationship_pid(relationship)
    if pid
      begin
        obj = ActiveFedora::Base.find(pid, :cast => true)
      rescue
        errs << I18n.t('batch.manifest.errors.relationship_object_not_found', :relationship => relationship, :pid => pid)
      end
      if obj && model
        object_class = DulHydra::Utils.reflection_object_class(DulHydra::Utils.relationship_object_reflection(model, relationship))
        errs << I18n.t('batch.manifest.errors.relationship_object_class_mismatch', :relationship => relationship, :exp_class => object_class, :actual_class => obj.class) unless obj.is_a?(object_class)
      end
    else
      errs << I18n.t('relationship_object_pid_not_determined', :relationship => relationship)
    end
    return errs
  end
  
  def validate_datastream_filepath(datastream)
    errs = []
    filepath = datastream_location(datastream)
    errs << I18n.t('batch.manifest.errors.datastream_filepath_error', :datastream => datastream, :filepath => filepath) unless File.readable?(filepath)
    return errs
  end
  
  def validate_datastream_list
    errs = []
    datastreams.each do |ds|
      errs << I18n.t('batch.manifest.errors.datastream_name_invalid', :name => ds) unless BatchObjectDatastream::DATASTREAMS.include?(ds)
    end
    return errs.flatten
  end
  
  def validate_checksum_type
    errs = []
    unless DulHydra::Datastreams::CHECKSUM_TYPES.include?(checksum_type)
      errs << I18n.t('batch.manifest.errors.checksum_type_invalid', :type => checksum_type)
    end
    return errs
  end
  
  def validate_checksum_file
    errs = []
    errs << I18n.t('batch.manifest.errors.checksum_file_error', :file => checksum_location) unless File.readable?(checksum_location)
    if errs.empty?
      checksums = File.open(checksum_location) { |f| Nokogiri::XML(f) }
      errs << I18n.t('batch.manifest.errors.checksum_file_not_xml', :file => checksum_location) if checksums.root.nil?
    end
    if errs.empty?
      errs << I18n.t('batch.manifest.errors.checksum_file_node_error', :node => checksum_node_xpath, :file => checksum_location) \
                  if checksums.xpath(checksum_node_xpath).empty?
    end
    if errs.empty?
      base_node_xpath = checksum_node_xpath.end_with?('/') ? checksum_node_xpath : "#{checksum_node_xpath}/"
      identifier_xpath = "#{base_node_xpath}#{checksum_identifier_element}"
      type_xpath = "#{base_node_xpath}#{checksum_type_xpath}"
      value_xpath = "#{base_node_xpath}#{checksum_value_xpath}"
      errs << I18n.t('batch.manifest.errors.checksum_file_node_error', :node => checksum_identifier_element, :file => checksum_location) \
                  if checksums.xpath(identifier_xpath).empty?
      errs << I18n.t('batch.manifest.errors.checksum_file_node_error', :node => checksum_type_xpath, :file => checksum_location) \
                  if checksums.xpath(type_xpath).empty?
      errs << I18n.t('batch.manifest.errors.checksum_file_node_error', :node => checksum_value_xpath, :file => checksum_location) \
                  if checksums.xpath(value_xpath).empty?
    end
    return errs
  end
  
  def validate_model
    errs = []
    model.constantize.new rescue errs << I18n.t('batch.manifest.errors.model_invalid', :model => model)
    return errs
  end
  
  def basepath
    manifest_hash[BASEPATH]
  end
  
  def batch
    @batch
  end
  
  def batch=(batch)
    @batch = batch
  end
  
  def batch_description
    manifest_hash[BATCH][DESCRIPTION] if manifest_hash[BATCH]
  end
  
  def batch_id
    manifest_hash[BATCH][ID] if manifest_hash[BATCH]
  end

  def batch_name
    manifest_hash[BATCH][NAME] if manifest_hash[BATCH]
  end
  
  def batch_user_email
    manifest_hash[BATCH][USER_EMAIL] if manifest_hash[BATCH]
  end
  
  def checksum_identifier_element
    if manifest_hash[CHECKSUM] && manifest_hash[CHECKSUM][IDENTIFIER_ELEMENT]
      manifest_hash[CHECKSUM][IDENTIFIER_ELEMENT]
    else
      'id'
    end
  end
  
  def checksum_location
    manifest_hash[CHECKSUM][LOCATION] if manifest_hash[CHECKSUM]
  end
  
  def checksum_node_xpath
    if manifest_hash[CHECKSUM] && manifest_hash[CHECKSUM][NODE_XPATH]
      manifest_hash[CHECKSUM][NODE_XPATH]
    else
      '/checksums/checksum'
    end
  end
  
  def checksum_type
    manifest_hash[CHECKSUM][TYPE] if manifest_hash[CHECKSUM]
  end
  
  def checksum_type?
    manifest_hash[CHECKSUM] && manifest_hash[CHECKSUM][TYPE]
  end
  
  def checksum_type_xpath
    if manifest_hash[CHECKSUM] && manifest_hash[CHECKSUM][TYPE_XPATH]
      manifest_hash[CHECKSUM][TYPE_XPATH]
    else
      'type'
    end
  end

  def checksum_value_xpath
    if manifest_hash[CHECKSUM] && manifest_hash[CHECKSUM][VALUE_XPATH]
      manifest_hash[CHECKSUM][VALUE_XPATH]
    else
      'value'
    end
  end
  
  def checksums
    return @checksums if @checksums
    if checksums?
      @checksums = File.open(manifest_hash[CHECKSUM][LOCATION]) { |f| Nokogiri::XML(f) }
    end
    return @checksums
  end
  
  def checksums?
    manifest_hash[CHECKSUM] && manifest_hash[CHECKSUM][LOCATION]
  end
  
  def datastream_extension(datastream_name)
    manifest_hash[datastream_name][EXTENSION] if manifest_hash[datastream_name]
  end
  
  def datastream_location(datastream_name)
    manifest_hash[datastream_name][LOCATION] if manifest_hash[datastream_name]
  end
  
  def datastreams
    manifest_hash[DATASTREAMS]
  end
  
  def label
    manifest_hash[LABEL]
  end
  
  def model
    manifest_hash[MODEL]
  end
  
  def manifest_hash
    @manifest_hash
  end
  
  def manifest_hash=(manifest_hash)
    @manifest_hash = manifest_hash
  end
  
  def objects
    objects = []
    manifest_objects = manifest_hash[OBJECTS]
    manifest_objects.each { |object_hash| objects << ManifestObject.new(object_hash, self) }
    return objects
  end
  
  def has_relationship?(relationship_name)
    manifest_hash[relationship_name] ? true : false
  end
  
  def relationship_autoidlength(relationship_name)
    manifest_hash[relationship_name][AUTOIDLENGTH] if manifest_hash[relationship_name] && manifest_hash[relationship_name].is_a?(Hash)
  end

  def relationship_id(relationship_name)  
    manifest_hash[relationship_name][ID] if manifest_hash[relationship_name] && manifest_hash[relationship_name].is_a?(Hash)
  end
  
  def relationship_batchid(relationship_name)  
    manifest_hash[relationship_name][BATCHID] if manifest_hash[relationship_name] && manifest_hash[relationship_name].is_a?(Hash)
  end
  
  def relationship_pid(relationship_name)
    if manifest_hash[relationship_name]    
      case
      when manifest_hash[relationship_name].is_a?(String)
        manifest_hash[relationship_name]
      when manifest_hash[relationship_name][PID]
        manifest_hash[relationship_name][PID]
      when manifest_hash[relationship_name][ID]
        pids = BatchObject.pid_from_identifier(manifest_hash[relationship_name][ID], manifest_hash[relationship_name][BATCHID])
        pids.last if pids
      end
    end
  end
  
end