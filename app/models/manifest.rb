class Manifest
  
  MANIFEST_KEYS = [ :basepath, :batch, :checksum, :description, :label, :model, :name, :objects, BatchObjectDatastream::DATASTREAMS, BatchObjectRelationship::RELATIONSHIPS ].flatten
  BATCH_KEYS = [ :description, :id, :name ]
  MANIFEST_CHECKSUM_KEYS = [ :location, :source, :type, :node_xpath, :identifier_element, :type_xpath, :value_xpath ]
  MANIFEST_DATASTREAM_KEYS = [ :extension, :location ]
  MANIFEST_RELATIONSHIP_KEYS = [ :autoidlength, :id, :pid ]

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
    manifest_hash[:basepath]
  end
  
  def batch
    return @batch if @batch
    begin
      if manifest_hash[:batch] && manifest_hash[:batch][:id]
        @batch = Batch.find(manifest_hash[:batch][:id].to_i)
      else
        name = manifest_hash[:batch][:name] if manifest_hash[:batch]
        description = manifest_hash[:batch][:description] if manifest_hash[:batch]
        @batch = Batch.create(:name => name, :description => description)
      end
    rescue ActiveRecord::RecordNotFound
      log.error("Cannot find Batch with id #{manifest_hash[:batch][:id]}")
    end
    return @batch
  end
  
  def checksum_identifier_element
    if manifest_hash[:checksum] && manifest_hash[:checksum][:identifier_element]
      manifest_hash[:checksum][:identifier_element]
    else
      "id"
    end
  end
  
  def checksum_node_xpath
    if manifest_hash[:checksum] && manifest_hash[:checksum][:node_xpath]
      manifest_hash[:checksum][:node_xpath]
    else
      "/checksums/checksum"
    end
  end
  
  def checksum_type
    manifest_hash[:checksum][:type] if manifest_hash[:checksum]
  end
  
  def checksum_type?
    manifest_hash[:checksum] && manifest_hash[:checksum][:type]
  end
  
  def checksum_type_xpath
    if manifest_hash[:checksum] && manifest_hash[:checksum][:type_xpath]
      manifest_hash[:checksum][:type_xpath]
    else
      "type"
    end
  end

  def checksum_value_xpath
    if manifest_hash[:checksum] && manifest_hash[:checksum][:value_xpath]
      manifest_hash[:checksum][:value_xpath]
    else
      "value"
    end
  end
  
  def checksums
    return @checksums if @checksums
    if checksums?
      @checksums = File.open(manifest_hash[:checksum][:location]) { |f| Nokogiri::XML(f) }
    end
    return @checksums
  end
  
  def checksums?
    manifest_hash[:checksum] && manifest_hash[:checksum][:location]
  end
  
  def datastream_extension(datastream_name)
    manifest_hash[datastream_name][:extension] if manifest_hash[datastream_name]
  end
  
  def datastream_location(datastream_name)
    manifest_hash[datastream_name][:location] if manifest_hash[datastream_name]
  end
  
  def datastreams
    manifest_hash[:datastreams]
  end
  
  def label
    manifest_hash[:label]
  end
  
  def model
    manifest_hash[:model]
  end
  
  def manifest_hash
    @manifest_hash
  end
  
  def manifest_hash=(manifest_hash)
    @manifest_hash = manifest_hash
  end
  
  def objects
    objects = []
    manifest_objects = manifest_hash[:objects]
    manifest_objects.each { |object_hash| objects << ManifestObject.new(object_hash, self) }
    return objects
  end
  
  def has_relationship?(relationship_name)
    manifest_hash[relationship_name] ? true : false
  end
  
  def relationship_autoidlength(relationship_name)
    manifest_hash[relationship_name][:autoidlength] if manifest_hash[relationship_name] && manifest_hash[relationship_name].is_a?(Hash)
  end

  def relationship_id(relationship_name)  
    manifest_hash[relationship_name][:id] if manifest_hash[relationship_name] && manifest_hash[relationship_name].is_a?(Hash)
  end
  
  def relationship_pid(relationship_name)
    if manifest_hash[relationship_name]
      if manifest_hash[relationship_name].is_a?(String)
        manifest_hash[relationship_name]
      else
        if manifest_hash[relationship_name][:pid]
          manifest_hash[relationship_name][:pid]        
        end
      end
    end
  end
  
end