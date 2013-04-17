module DulHydra::BatchIngest
  class BatchIngest
    
    def ingest(ingest_object)
      if ingest_object.valid?
        repo_object = ingest_object.model.constantize.new
        repo_object.label = ingest_object.label if ingest_object.label
        repo_object.admin_policy = AdminPolicy.find(ingest_object.admin_policy, :cast => true) if ingest_object.admin_policy
        ingest_object.data.each {|d| repo_object = add_datastream(repo_object, d)} if ingest_object.data
        repo_object.parent = ActiveFedora::Base.find(ingest_object.parent, :cast => true) if ingest_object.parent
        repo_object.collection = Collection.find(ingest_object.collection, :cast => true) if ingest_object.collection
        repo_object.save
      end
      return repo_object
    end
  
    private
    
    def add_datastream(repo_object, data)
      case data[:payload_type]
      when "bytes"
        repo_object.datastreams[data[:datastream_name]].content = data[:payload]
      when "filename"
        data_file = File.open(data[:payload])
        repo_object.datastreams[data[:datastream_name]].content_file = data_file
        repo_object.save # save the object to the repository before we close the file 
        data_file.close
      end
      repo_object.generate_thumbnail! if data[:datastream_name].eql?(DulHydra::Datastreams::CONTENT)
      return repo_object
    end
  end
end