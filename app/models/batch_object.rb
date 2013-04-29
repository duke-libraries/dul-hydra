class BatchObject < ActiveRecord::Base
  attr_accessible :admin_policy, :identifier, :label, :model, :operation, :parent, :pid, :target_for
  belongs_to :batch, :inverse_of => :batch_objects
  has_many :batch_object_datastreams, :inverse_of => :batch_object
  
  OPERATION_INGEST = "INGEST"
  OPERATION_UPDATE = "UPDATE"
  
  VERIFICATION_PASS = "PASS"
  VERIFICATION_FAIL = "FAIL"
  
  OPERATIONS = [ OPERATION_INGEST, OPERATION_UPDATE ]
  SUPPORTED_OPERATIONS = [ OPERATION_INGEST ]
   
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
  
  def ingest(opts = {})
    dryrun = opts.fetch(:dryrun, false)
    raise "Ingest action invalid when object operation is #{operation}" unless operation.eql?(OPERATION_INGEST)
    repo_object = create_repository_object(dryrun)
    update_attributes(:pid => repo_object.pid) unless dryrun
    verifications = dryrun ? nil : verify_repository_object
    [ repo_object, verifications ]
  end
  
  private
  
  def create_repository_object(dryrun)
    repo_object = model.constantize.new
    repo_object.label = label if label
    repo_object.admin_policy = AdminPolicy.find(admin_policy, :cast => true) if admin_policy
    batch_object_datastreams.each {|d| repo_object = add_datastream(repo_object, d, dryrun)} if batch_object_datastreams
    repo_object.parent = ActiveFedora::Base.find(parent, :cast => true) if parent
    repo_object.collection = Collection.find(target_for, :cast => true) if target_for
    repo_object.save unless dryrun
    repo_object
  end
  
  def verify_repository_object
    verifications = {}
    begin
      repo_object = ActiveFedora::Base.find(pid, :cast => true)
    rescue ActiveFedora::ObjectNotFound
      verifications["pid"] = VERIFICATION_FAIL
    else
      verifications["pid"] = VERIFICATION_PASS
      verifications["model"] = verify_model(repo_object) if model
      verifications["label"] = repo_object.label.eql?(label) if label
      verifications["admin policy"] = verify_admin_policy(repo_object) if admin_policy
      batch_object_datastreams.each { |d| verifications[d.name] = verify_datastream(repo_object, d) } if batch_object_datastreams
      verifications["parent"] = verify_parent(repo_object) if parent
      verifications["collection"] = verify_target_for(repo_object) if target_for
    end
    verifications
  end
  
  def verify_model(repo_object)
    begin
      if repo_object.class.eql?(model.constantize)
        return true
      else
        return false
      end
    rescue NameError
      return false
    end
  end

  def verify_admin_policy(repo_object)
    return repo_object.admin_policy &&
            repo_object.admin_policy.pid.eql?(admin_policy) &&
            repo_object.admin_policy.class.eql?(AdminPolicy) 
  end
  
  def verify_parent(repo_object)
    return repo_object.parent &&
            repo_object.parent.pid.eql?(parent) &&
            repo_object.parent.class.eql?(parent_class) 
  end
  
  def verify_target_for(repo_object)
    return repo_object.collection &&
            repo_object.collection.pid.eql?(target_for) &&
            repo_object.collection.class.eql?(Collection) 
  end

  def add_datastream(repo_object, datastream, dryrun)
    case datastream[:payload_type]
    when BatchObjectDatastream::PAYLOAD_TYPE_BYTES
      repo_object.datastreams[datastream[:name]].content = datastream[:payload]
    when BatchObjectDatastream::PAYLOAD_TYPE_FILENAME
      datastream_file = File.open(datastream[:payload])
      repo_object.datastreams[datastream[:name]].content_file = datastream_file
      repo_object.save unless dryrun # save the object to the repository before we close the file 
      datastream_file.close
    end
    if datastream[:name].eql?(DulHydra::Datastreams::CONTENT)
      if dryrun
        repo_object.generate_thumbnail
      else
        repo_object.generate_thumbnail!
      end
    end
    puts repo_object.datastreams
    return repo_object
  end
  
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
    when OPERATION_INGEST
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
      if d[:payload_type].eql?(BatchObjectDatastream::PAYLOAD_TYPE_FILENAME)
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
