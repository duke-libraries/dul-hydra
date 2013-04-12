module DulHydra::BatchIngest
  class BatchIngest
    
    def ingest(ingest_object)
      if ingest_object.valid?
        repo_object = ingest_object.model.constantize.new
        
        repo_object.save
      end
      return repo_object
    end
  
  end
end