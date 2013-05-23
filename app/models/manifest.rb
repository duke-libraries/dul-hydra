class Manifest
  
  AUTOIDLENGTH = "autoidlength"
  BASEPATH = "basepath"
  BATCH = "batch"
  CHECKSUM = "checksum"
  DATASTREAMS = "datastreams"
  DESCRIPTION = "description"
  EXTENSION = "extension"
  ID = "id"
  IDENTIFIER_ELEMENT = "identifier_element"
  LABEL = "label"
  LOCATION = "location"
  MODEL = "model"
  NAME = "name"
  NODE_XPATH = "node_xpath"
  OBJECTS = "objects"
  PID = "pid"
  SOURCE = "source"
  TYPE = "type"
  TYPE_XPATH = "type_xpath"
  USER = "user"
  VALUE_XPATH = "value_xpath"  

  MANIFEST_KEYS = [ BASEPATH, BATCH, CHECKSUM, DATASTREAMS, DESCRIPTION, LABEL, MODEL, NAME, OBJECTS, BatchObjectDatastream::DATASTREAMS, BatchObjectRelationship::RELATIONSHIPS ].flatten
  BATCH_KEYS = [ DESCRIPTION, ID, NAME ]
  MANIFEST_CHECKSUM_KEYS = [ LOCATION, SOURCE, TYPE, NODE_XPATH, IDENTIFIER_ELEMENT, TYPE_XPATH, VALUE_XPATH ]
  MANIFEST_DATASTREAM_KEYS = [ EXTENSION, LOCATION ]
  MANIFEST_RELATIONSHIP_KEYS = [ AUTOIDLENGTH, ID, PID ]
  
  def initialize(manifest_filepath=nil)
    if manifest_filepath
      begin
        @manifest_hash = File.open(manifest_filepath) { |f| YAML::load(f) }
      rescue
        raise ArgumentError, "Unable to load manifest file: #{manifest_filepath}"
      end
    else
      @manifest_hash = {}
    end
  end
  
  def basepath
    manifest_hash[BASEPATH]
  end
  
  def batch
    return @batch if @batch
    begin
      if manifest_hash[BATCH] && manifest_hash[BATCH][ID]
        @batch = Batch.find(manifest_hash[BATCH][ID].to_i)
      else
        name = manifest_hash[BATCH][NAME] if manifest_hash[BATCH]
        description = manifest_hash[BATCH][DESCRIPTION] if manifest_hash[BATCH]
        @batch = Batch.create(NAME => name, DESCRIPTION => description)
      end
    rescue ActiveRecord::RecordNotFound
      log.error("Cannot find Batch with id #{manifest_hash[BATCH][ID]}")
    end
    return @batch
  end
  
  def checksum_identifier_element
    if manifest_hash[CHECKSUM] && manifest_hash[CHECKSUM][IDENTIFIER_ELEMENT]
      manifest_hash[CHECKSUM][IDENTIFIER_ELEMENT]
    else
      "id"
    end
  end
  
  def checksum_node_xpath
    if manifest_hash[CHECKSUM] && manifest_hash[CHECKSUM][NODE_XPATH]
      manifest_hash[CHECKSUM][NODE_XPATH]
    else
      "/checksums/checksum"
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
      "type"
    end
  end

  def checksum_value_xpath
    if manifest_hash[CHECKSUM] && manifest_hash[CHECKSUM][VALUE_XPATH]
      manifest_hash[CHECKSUM][VALUE_XPATH]
    else
      "value"
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
  
  def relationship_pid(relationship_name)
    if manifest_hash[relationship_name]
      if manifest_hash[relationship_name].is_a?(String)
        manifest_hash[relationship_name]
      else
        if manifest_hash[relationship_name][PID]
          manifest_hash[relationship_name][PID]        
        end
      end
    end
  end
  
end