class SetDefaultStructuresAfterSuccessfulBatchIngest

  attr_reader :batch
  attr_accessor :object_ids

  def self.call(*args)
    event = ActiveSupport::Notifications::Event.new(*args)
    service = SetDefaultStructuresAfterSuccessfulBatchIngest.new(batch_id: event.payload[:batch_id])
    service.enqueue_needed_default_structures
  end

  def initialize(batch_id:)
    @batch = Ddr::Batch::Batch.find(batch_id)
    @object_ids = Set.new
  end

  def enqueue_needed_default_structures
    examine_batch_objects
    enqueue_jobs
  end

  private

  def examine_batch_objects
    batch.batch_objects.each do |batch_object|
      handle_ingest_object(batch_object) if batch_object.is_a?(Ddr::Batch::IngestBatchObject)
    end
  end

  def handle_ingest_object(batch_object)
    repo_object = ActiveFedora::Base.find(batch_object.pid)
    if repo_object.can_have_struct_metadata?
      unless repo_object.has_struct_metadata?
        object_ids.add(repo_object.pid)
      end
    end
    if repo_object.parent.present?
      handle_ingest_object_parent(repo_object.parent)
    end
  end

  def handle_ingest_object_parent(parent)
    if parent.can_have_struct_metadata?
      if parent.has_struct_metadata?
        object_ids.add(parent.pid) if parent.structure.repository_maintained?
      else
        object_ids.add(parent.pid)
      end
    end
  end

  def enqueue_jobs
    object_ids.each do |object_id|
      Resque.enqueue(GenerateDefaultStructureJob, object_id)
    end
  end

end
