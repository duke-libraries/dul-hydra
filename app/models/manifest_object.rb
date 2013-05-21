class ManifestObject
  
  OBJECT_KEYS = [ :checksum, :identifier, :label, :model, BatchObjectDatastream::DATASTREAMS, BatchObjectRelationship::RELATIONSHIPS].flatten
  OBJECT_CHECKSUM_KEYS = [ :type, :value ]
  OBJECT_RELATIONSHIP_KEYS = [ :autoidlength, :id, :pid ]

  def initialize(object_hash, manifest)
    @object_hash = object_hash
    @manifest = manifest
  end
  
  def batch
    manifest.batch
  end
  
  def checksum
    if object_hash[:checksum]
      if object_hash[:checksum][:value]
        object_hash[:checksum][:value]
      else
        object_hash[:checksum]
      end
    else
      if manifest.checksums?
        checksums = manifest.checksums
        checksum_node = checksums.xpath("#{manifest.checksum_node_xpath}[#{manifest.checksum_identifier_element}[text() = '#{key_identifier}']]")
        checksum_node.xpath(manifest.checksum_value_xpath).text()
      end
    end
  end
  
  def checksum?
    object_hash[:checksum] || manifest.checksums?
  end

  def checksum_type
    case
    when object_hash[:checksum] && object_hash[:checksum][:type]
      object_hash[:checksum][:type]
    when manifest.checksums?
      checksums = manifest.checksums
      checksum_node = checksums.xpath("#{manifest.checksum_node_xpath}[#{manifest.checksum_identifier_element}[text() = '#{key_identifier}']]")
      checksum_node.xpath(manifest.checksum_type_xpath).text()
    when manifest.checksum_type
      manifest.checksum_type
    end    
  end

  def checksum_type?
    (object_hash[:checksum] && object_hash[:checksum][:type]) || manifest.checksums? || manifest.checksum_type?
  end

  def datastream_filepath(datastream_name)
    datastream = object_hash[datastream_name]
    filepath = case
      # canonical location is @manifest[:basepath] + datastream (name)
      # canonical filename is batch_object.identifier
      # canonical extension is ".xml"
    when datastream.nil?
      # (manifest datastream location || canonical location) + canonical filename + (manifest datastream extension || canonical extension)
      location = manifest.datastream_location(datastream_name) || File.join(manifest.basepath, datastream_name)
      extension = manifest.datastream_extension(datastream_name) || ".xml"
      File.join(location, key_identifier + extension)
    when datastream.start_with?(File::PATH_SEPARATOR)
      # datastream contains full path, file name, and extension
      datastream
    else
      # (manifest datastream location || canonical location) + datastream
      location = manifest.datastream_location(datastream) || File.join(manifest.basepath, datastream_name)
      File.join(location, datastream)
    end
  end
  
  def datastreams
    object_hash[:datastreams] || manifest.datastreams
  end
  
  def key_identifier
    case object_hash[:identifier]
    when String
      object_hash[:identifier]
    when Array
      object_hash[:identifier].first
    end
  end
  
  def label
    object_hash[:label] || manifest.label
  end
  
  def model
    object_hash[:model] || manifest.model
  end
  
  def manifest
    @manifest
  end
  
  def manifest=(manifest)
    @manifest = manifest
  end
  
  def object_hash
    @object_hash
  end
  
  def object_hash=(object_hash)
    @object_hash = object_hash
  end

  def has_relationship?(relationship_name)
    object_hash[relationship_name] || manifest.has_relationship?(relationship_name) ? true : false
  end
  
  def relationship_autoidlength(relationship_name)
    autoidlength = nil
    if object_hash[relationship_name]
      if object_hash[relationship_name].is_a?(Hash)
        autoidlength = object_hash[relationship_name][:autoidlength]
      end
    end
    autoidlength = manifest.relationship_autoidlength(relationship_name) unless autoidlength
    return autoidlength
  end
  
  def relationship_id(relationship_name)
    id = nil
    if object_hash[relationship_name]
      if object_hash[relationship_name].is_a?(Hash)
        id = object_hash[relationship_name][:id]
      end
    end
    id = manifest.relationship_id(relationship_name) unless id
    return id
  end
  
  def relationship_pid(relationship_name)
    pid = explicit_relationship_pid(relationship_name)
    unless pid
      id = relationship_id(relationship_name)
      unless id
        autoidlength = relationship_autoidlength(relationship_name)
        index = autoidlength - 1
        id = key_identifier[0..index]
      end
      if id
        found_objects = BatchObject.where("identifier = ?", id)
        if found_objects
          pid = found_objects.first.pid if found_objects.size.eql?(1)
        end
      end
    end
    return pid
  end
  
  def explicit_relationship_pid(relationship_name)
    pid = nil
    if object_hash[relationship_name]
      if object_hash[relationship_name].is_a?(String)
        pid = object_hash[relationship_name]
      else
        pid = object_hash[relationship_name][:pid]
      end
    end
    pid = manifest.relationship_pid(relationship_name) unless pid
    return pid
  end
  
end