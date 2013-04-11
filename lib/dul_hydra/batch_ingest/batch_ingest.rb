module DulHydra::BatchIngest
  class BatchIngest
    
    def initialize(objects)
      @objects = objects
    end
    
    def ingest()
      if validate_batch
        #code
      end
    end
    
    def validate_batch()
      valid = true
      if @objects.is_a?(Array)
        @objects.each do |object|
          valid = false unless validate_object(object)
        end
      else
        valid = validate_object(@objects)
      end
      return valid
    end
    
    def validate_object(object)
      return false unless object.is_a?(IngestObject)
    end
    
  end
end