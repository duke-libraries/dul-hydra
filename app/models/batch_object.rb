class BatchObject < ActiveRecord::Base
  attr_accessible :identifier, :label, :model, :pid
  belongs_to :batch, :inverse_of => :batch_objects
  has_many :batch_object_datastreams, :inverse_of => :batch_object
  has_many :batch_object_relationships, :inverse_of => :batch_object
  
  VERIFICATION_PASS = "PASS"
  VERIFICATION_FAIL = "FAIL"
  
  PRESERVATION_EVENT_DETAIL = <<-EOS
    DulHydra version #{DulHydra::VERSION}
    Batch object database id: %{batch_id}
    Batch object identifier: %{identifier}
    Model: %{model}
  EOS

  def validate
    validation = DulHydra::Models::Validation.new
    validation.errors += validate_required_attributes
    validation.errors += validate_model if model
    validation.errors += validate_datastreams if batch_object_datastreams
    validation.errors += validate_relationships if batch_object_relationships
    return validation
  end
  
  private
  
  def validate_model
    errs = []
    begin
      model.constantize
    rescue NameError
      errs << "Invalid model name: #{model}"
    end
    return errs
  end
  
  def validate_datastreams
    errs = []
    batch_object_datastreams.each do |d|
      unless model.constantize.new.datastreams.keys.include?(d.name)
        errs << "Invalid datastream name for #{model}: #{d.name}"
      end
      unless BatchObjectDatastream::PAYLOAD_TYPES.include?(d.payload_type)
        errs << "Invalid payload type for #{d.name} datastream: #{d.payload_type}"
      end
      if d.payload_type.eql?(BatchObjectDatastream::PAYLOAD_TYPE_FILENAME)
        unless File.readable?(d.payload)
          errs << "Missing or unreadable file for #{d[:name]} datastream: #{d[:payload]}"
        end
      end
      if d.checksum && !d.checksum_type
        errs << "Must specify checksum type if providing checksum for #{d.name} datastream"
      end
      if d.checksum_type
        unless BatchObjectDatastream::CHECKSUM_TYPES.include?(d.checksum_type)      
          errs << "Invalid checksum type for #{d.name} datastream: #{d.checksum_type}"
        end
      end      
    end
    return errs
  end
  
  def validate_relationships
    errs = []
    batch_object_relationships.each do |r|
      unless BatchObjectRelationship::OBJECT_TYPES.include?(r[:object_type])
        errs << "Invalid object_type for #{r[:name]} relationship: #{r[:object_type]}"
      end
      if r[:object_type].eql?(BatchObjectRelationship::OBJECT_TYPE_PID)
        begin
          obj = ActiveFedora::Base.find(r[:object], :cast => true)
        rescue ActiveFedora::ObjectNotFoundError
          errs << "#{r[:name]} relationship object does not exist: #{r[:object]}"
        else
          relationship_reflection = relationship_object_reflection(model, r[:name])
          if relationship_reflection
            klass = reflection_object_class(relationship_reflection)
            if klass
              errs << "#{r[:name]} relationship object #{r[:object]} exists but is not a(n) #{klass}" unless obj.is_a?(klass)
            end
          else
            errs << "#{model} does not define a(n) #{r[:name]} relationship"
          end
        end
      end
    end
    return errs
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
    return repo_object
  end
  
  def add_relationship(repo_object, relationship)
    relationship_object = case relationship[:object_type]
    when BatchObjectRelationship::OBJECT_TYPE_PID
      ActiveFedora::Base.find(relationship[:object], :cast => true)
    end
    repo_object.send("#{relationship[:name]}=", relationship_object)
    return repo_object
  end
  
  def verify_repository_object
    verifications = {}
    begin
      repo_object = ActiveFedora::Base.find(pid, :cast => true)
    rescue ActiveFedora::ObjectNotFound
      verifications["Object exists in repository"] = VERIFICATION_FAIL
    else
      verifications["Object exists in repository"] = VERIFICATION_PASS
      verifications["Object is correct model"] = verify_model(repo_object) if model
      verifications["Object has correct label"] = verify_label(repo_object) if label
      if batch_object_datastreams
        batch_object_datastreams.each do |d|
          verifications["#{d.name} datastream present and not empty"] = verify_datastream(repo_object, d)
        end
      end
      if batch_object_relationships
        batch_object_relationships.each do |r|
          verifications["#{r.name} relationship is correct"] = verify_relationship(repo_object, r)
        end
      end
      
    end
    verifications
  end
  
  def verify_model(repo_object)
    begin
      if repo_object.class.eql?(model.constantize)
        return VERIFICATION_PASS
      else
        return VERIFICATION_FAIL
      end
    rescue NameError
      return VERIFICATION_FAIL
    end
  end

  def verify_label(repo_object)
    repo_object.label.eql?(label) ? VERIFICATION_PASS : VERIFICATION_FAIL
  end
  
  def verify_datastream(repo_object, datastream)
    if repo_object.datastreams.keys.include?(datastream.name) &&
        !repo_object.datastreams[datastream.name].profile.empty? &&
        !repo_object.datastreams[datastream.name].size.eql?(0)
      VERIFICATION_PASS
    else
      VERIFICATION_FAIL
    end
  end
  
  def verify_relationship(repo_object, relationship)
    relationship_reflection = relationship_object_reflection(model, relationship.name)
    relationship_object_class = reflection_object_class(relationship_reflection)
    relationship_object = repo_object.send(relationship.name)
    if !relationship_object.nil? &&
        relationship_object.pid.eql?(relationship.object) &&
        relationship_object.is_a?(relationship_object_class)
      VERIFICATION_PASS
    else
      VERIFICATION_FAIL
    end
  end
  
  def relationship_object_reflection(model, relationship_name)
    reflection = nil
    if model
      begin
        reflections = model.constantize.reflections
      rescue NameError
        # nothing to do here except that we can't return the appropriate reflection
      else
        reflections.each do |reflect|
          if reflect[0].eql?(relationship_name.to_sym)
            reflection = reflect
          end
        end
      end
    end
    return reflection
  end

  def reflection_object_class(reflection)
    reflection_object_model = nil
    klass = nil
    if reflection[1].options[:class_name]
      reflection_object_model = reflection[1].options[:class_name]
    else
      reflection_object_model = ActiveSupport::Inflector.camelize(reflection[0])
    end
    if reflection_object_model
      begin
        klass = reflection_object_model.constantize
      rescue NameError
        # nothing to do here except that we can't return the reflection object class
      end
    end
    return klass
  end
  
  def create_preservation_event(event_type, event_outcome, outcome_details, repository_object)
    event_label = case event_type
    when PreservationEvent::INGESTION
      "Object ingestion"
    when PreservationEvent::VALIDATION
      "Object ingest validation"
    end
    event = PreservationEvent.new(:label => event_label,
                                  :event_type => event_type,
                                  :event_date_time => Time.now.utc.strftime(PreservationEvent::DATE_TIME_FORMAT),
                                  :event_detail => event_detail,
                                  :event_outcome => event_outcome,
                                  :event_outcome_detail_note => outcome_details.join("\n"),
                                  :linking_object_id_type => PreservationEvent::OBJECT,
                                  :linking_object_id_value => repository_object.internal_uri,
                                  :for_object => repository_object)
    event.save
  end
  
  def event_detail
    PRESERVATION_EVENT_DETAIL % {
      :batch_id => id,
      :identifier => identifier,
      :model => model
    }
  end

end
