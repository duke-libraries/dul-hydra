class BatchObject < ActiveRecord::Base
  attr_accessible :admin_policy, :identifier, :label, :model, :operation, :parent, :pid, :target_for
  belongs_to :batch, :inverse_of => :batch_objects
  has_many :batch_object_datastreams, :inverse_of => :batch_object
  
  INGEST = "INGEST"
  UPDATE = "UPDATE"
  
  OPERATIONS = [ INGEST, UPDATE ]
  SUPPORTED_OPERATIONS = [ INGEST ]
   
  def validate
    validation = DulHydra::Models::Validation.new
    validation.errors += validate_operation
    validation.errors += validate_required_attributes if SUPPORTED_OPERATIONS.include?(operation)
    validation.errors += validate_model if model
    validation.errors += validate_pid(admin_policy, AdminPolicy) if admin_policy
    validation.errors += validate_datastreams if batch_object_datastreams
    validation.errors += validate_parent(parent) if parent
    validation.errors += validate_pid(target_for, Collection) if target_for
    return validation
  end
    
  private
  
  def validate_operation
    errs = []
    if operation
      if OPERATIONS.include?(operation)
        errs << "Unsupported operation: #{operation}" unless SUPPORTED_OPERATIONS.include?(operation)
      else
        errs << "Invalid operation: #{operation}"
      end
    else
      errs << "Missing operation"
    end    
    return errs
  end
  
  def validate_required_attributes
    errs = []
    case operation
    when INGEST
      errs << "Model required for INGEST operation" unless model
    end
    return errs
  end
  
  def validate_model
    errs = []
    begin
      model.constantize
    rescue NameError
      errs << "Invalid model name: #{model}"
    end
    return errs
  end
  
  def validate_pid(pid, klass)
    errs = []
    begin
      obj = ActiveFedora::Base.find(pid, :cast => true)
    rescue ActiveFedora::ObjectNotFoundError
      errs << "Specified #{klass} does not exist: #{pid}"
    else
      errs << "#{pid} exists but is not a(n) #{klass}" unless obj.is_a?(klass)
    end
    return errs
  end
  
  def validate_parent(pid)
    errs = []
    klass = parent_class
    if klass
      errs << validate_pid(pid, klass)
      errs.flatten!
    else
      errs << "Unable to determine parent class"
    end
    return errs
  end
  
  def validate_datastreams
    errs = []
    batch_object_datastreams.each do |d|
      unless BatchObjectDatastream::PAYLOAD_TYPES.include?(d[:payload_type])
        errs << "Invalid payload_type for #{d[:name]} datastream: #{d[:payload_type]}"
      end
      if d[:payload_type].eql?(BatchObjectDatastream::FILENAME)
        unless File.readable?(d[:payload])
          errs << "Missing or unreadable file for #{d[:name]} datastream: #{d[:payload]}"
        end
      end
    end
    return errs
  end
  
  def parent_class
    parent_model = nil
    if model
      begin
        reflections = model.constantize.reflections
      rescue NameError
        # nothing to do here except that we can't determine the parent class
      else
        reflections.each do |reflection|
          if (reflection[0] == :collection) || (reflection[0] == :container) || (reflection[0] == :parent)
            parent_model = reflection[1].options[:class_name]
          end
        end
        begin
          parent_klass = parent_model.constantize
        rescue NameError
          # nothing to do here except that we can't return a parent class
        end
      end
      return parent_klass
    end
  end
  

end
