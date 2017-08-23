class UpdateComponentStructure

  attr_reader :object_id

  def self.call(*args)
    return false unless DulHydra.auto_update_structures
    event = ActiveSupport::Notifications::Event.new(*args)
    payload = event.payload
    return false if payload[:skip_structure_updates]
    return false if relevant_new_datastreams(payload[:new_datastreams]).empty?
    SetDefaultStructure.new(payload[:pid]).enqueue_default_structure_job
  end

  def self.relevant_new_datastreams(new_datastreams)
    Component::STRUCTURALLY_RELEVANT_DATASTREAMS & new_datastreams
  end

end
