module DulHydra::BatchIngest
  class ManifestObject

    PAYLOAD_TYPES = [:bytes, :uri]
    
    attr_accessible :model,        # Name of ActiveFedora class
                    :admin_policy, # Admin Policy Object PID
                    :label,        # String to use as object label
                    :metadata,     # Array of hashes containing :name, :payload, :payload_type
                    :content,      # Hash containing :payload, :payload_type
                    :parent,       # PID of parent object
                    :collection   # PID of collection (for Targets)
  end
  
end

