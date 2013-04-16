module DulHydra::BatchIngest
  class IngestObject

    PAYLOAD_TYPES = ["bytes", "filename"]
    
    attr_accessor :model,        # Name of ActiveFedora class
                  :admin_policy, # Admin Policy Object PID
                  :label,        # String to use as object label
                  :data,         # Array of hashes containing :datastream_name, :payload, :payload_type
                  :parent,       # PID of parent object
                  :collection    # PID of collection (for Targets)
    
    def valid?()
      validate.empty?
    end
    
    def validate()
      errors = []
      errors += validate_model()
      errors += validate_pid(admin_policy, AdminPolicy) if admin_policy
      errors += validate_data() if data
      errors += validate_pid(parent, parent_class()) if parent
      errors += validate_pid(collection, Collection) if collection
      return errors
    end

    private
    
    def parent_class()
      parent_model = nil
      if validate_model.empty?
        reflections = model.constantize.reflections
        reflections.each do |reflection|
          if (reflection[0] == :collection) || (reflection[0] == :container) || (reflection[0] == :parent)
            parent_model = reflection[1].options[:class_name]
          end
        end
      end
      return parent_model.constantize if parent_model
    end
    
    def validate_model()
      errs = []
      if model
        begin
          model.constantize
        rescue NameError
          errs << "Invalid model name: #{model}"
        end
      else
        errs << "Missing model name"
      end
      return errs
    end
    
    def validate_pid(pid, klass)
      errs = []
        obj = ActiveFedora::Base.find(pid, :cast => true)
      rescue ActiveFedora::ObjectNotFoundError
        errs << "Specified #{klass} does not exist: #{pid}"
      else
        errs << "#{pid} exists but is not a(n) #{klass}" unless obj.is_a?(klass)
      return errs
    end
    
    def validate_data()
      errs = []
      data.each do |d|
        errs << "Invalid payload_type for #{d[:datastream_name]} datastream: #{d[:payload_type]}" unless PAYLOAD_TYPES.include?(d[:payload_type])
        if d[:payload_type].eql?("filename")
          unless File.readable?(d[:payload])
            errs << "Missing or unreadable file for #{d[:datastream_name]} datastream: #{d[:payload]}"
          end
        end
      end
      return errs
    end
    
  end
  
end

