require 'yaml'

module DulHydra::BatchIngest
  class IngestObject

    PAYLOAD_TYPES = ["bytes", "filename"]
    
    attr_accessor :identifier,   # Optional string used to identify the object
                  :model,        # Name of ActiveFedora class
                  :admin_policy, # Admin Policy Object PID
                  :label,        # String to use as object label
                  :data,         # Array of hashes containing :datastream_name, :payload, :payload_type
                  :parent,       # PID of parent object
                  :target_for    # PID of collection (for Targets)
    
    def initialize(identifier=nil)
      if identifier
        @identifier = identifier
      else
        @identifier = SecureRandom.uuid
      end
    end
    
    def valid?()
      validate.valid?
    end

    def validate()
      validation = DulHydra::Models::Validation.new
      validation.errors += validate_model()
      validation.errors += validate_pid(admin_policy, AdminPolicy) if admin_policy
      validation.errors += validate_data() if data
      validation.errors += validate_pid(parent, parent_class()) if parent
      validation.errors += validate_pid(target_for, Collection) if target_for
      return validation
    end
    
    def self.from_yaml(yaml)
      YAML::load(yaml)
    end
    
    def self.read_from_yaml_file(filepath)
      begin
        self.from_yaml(File.open(filepath))
      rescue => e
        puts "Error parsing from YAML file: #{e.message}"
      end
    end
    
    def to_yaml()
      YAML::dump(self)
    end
    
    def write_to_yaml_file(filepath)
      begin
        File.open(filepath, 'w') { |f| f.write(self.to_yaml) }
      rescue => e
        puts "Could not write YAML to file: #{e.message}"
      end
    end

    alias eql? ==
    
    def ==(o)
      if o.is_a? IngestObject
        @model == o.model &&
        @admin_policy == o.admin_policy &&
        @label == o.label &&
        @data == o.data &&
        @parent == o.parent &&
        @target_for == o.target_for
      else
        false
      end
    end
    
    def to_s()
      to_yaml()
    end
    
    
    private
    
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
        unless PAYLOAD_TYPES.include?(d[:payload_type])
          errs << "Invalid payload_type for #{d[:datastream_name]} datastream: #{d[:payload_type]}"
        end
        if d[:payload_type].eql?("filename")
          unless File.readable?(d[:payload])
            errs << "Missing or unreadable file for #{d[:datastream_name]} datastream: #{d[:payload]}"
          end
        end
      end
      return errs
    end
    
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
    
  end
  
end

