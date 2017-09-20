class SetDefaultStructure

  attr_reader :object

  def self.call(*args)
    return false unless DulHydra.auto_update_structures
    event = ActiveSupport::Notifications::Event.new(*args)
    payload = event.payload
    return false if payload[:skip_structure_updates]
    service = SetDefaultStructure.new(payload[:pid])
    service.enqueue_default_structure_job
  end

  def initialize(repo_id)
    @object = ActiveFedora::Base.find(repo_id)
  end

  def enqueue_default_structure_job
    if default_structure_needed?
      Resque.enqueue(GenerateDefaultStructureJob, object.id)
    end
  end

  def default_structure_needed?
    if object.can_have_struct_metadata?
      if object.has_struct_metadata?
        if object.structure.repository_maintained?
          true
        else
          false
        end
      else
        true
      end
    else
      false
    end
  end
end
