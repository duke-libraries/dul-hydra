module DulHydra::BatchIngest
  class IngestObject

    PAYLOAD_TYPES = ["bytes", "uri"]
    
    attr_accessor :model,        # Name of ActiveFedora class
                  :admin_policy, # Admin Policy Object PID
                  :label,        # String to use as object label
                  :metadata,     # Array of hashes containing :datastream_name, :payload, :payload_type
                  :content,      # Hash containing :payload, :payload_type
                  :parent,       # PID of parent object
                  :collection    # PID of collection (for Targets)
    
    def valid?()
      begin
        model.constantize
      rescue NameError
        return false
      end
      return true
    end
    
  end
  
end

