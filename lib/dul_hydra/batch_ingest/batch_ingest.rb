module DulHydra::BatchIngest
  class BatchIngest
    
    def ingest(ingest_object)
      if ingest_object.valid?
        repo_object = ingest_object.model.constantize.new
        repo_object.label = ingest_object.label
        repo_object.admin_policy = AdminPolicy.find(ingest_object.admin_policy)
        ingest_object.metadata.each {|m| repo_object = add_metadata_datastream(repo_object, m)}
        repo_object.save
      end
      return repo_object
    end
  
    private
    
    def add_metadata_datastream(repo_object, metadata)
      case metadata[:payload_type]
      when "bytes"
        repo_object.datastreams[metadata[:datastream_name]].content = metadata[:payload]
      when "uri"
        metadata_file = File.open(metadata[:payload]) { |f| f.read }
        repo_object.datastreams[metadata[:datastream_name]].content_file = metadata_file
#        repo_object.save
#        metadata_file.close
      end
      return repo_object
    end
  end
end