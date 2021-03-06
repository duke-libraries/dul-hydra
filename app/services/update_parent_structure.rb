class UpdateParentStructure

  attr_reader :object_id, :parent_id

  def self.call(*args)
    return false unless DulHydra.auto_update_structures
    event = ActiveSupport::Notifications::Event.new(*args)
    payload = event.payload
    return false if payload[:skip_structure_updates]
    service = UpdateParentStructure.new(event.payload[:pid], event.payload[:parent])
    service.run
  end

  def initialize(object_id, parent_id=nil)
    @object_id = object_id
    @parent_id = parent_id
  end

  def run
    calculate_parent_structure(parent_id) if parent_id
  end

  def calculate_parent_structure(parent_id)
    parent_service = SetDefaultStructure.new(parent_id)
    parent_service.enqueue_default_structure_job
  end

end
