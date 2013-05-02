class IngestBatchObject < BatchObject

  def validate_required_attributes
    errs = []
    errs << "Model required for INGEST operation" unless model
    errs
  end

  def process(opts = {})
    ingest(opts)
  end
  
  private
  
  Results = Struct.new(:repository_object, :verified, :verifications)

  def ingest(opts = {})
    dryrun = opts.fetch(:dryrun, false)
    repo_object = create_repository_object(dryrun)
    if !repo_object.nil? && !dryrun
      ingest_outcome_detail = []
      ingest_outcome_detail << "Ingested #{model} #{identifier} into #{repo_object.pid}"
      create_preservation_event(PreservationEvent::INGESTION,
                                PreservationEvent::SUCCESS,
                                ingest_outcome_detail,
                                repo_object)
      update_attributes(:pid => repo_object.pid)
      verifications = verify_repository_object
      verification_outcome_detail = []
      verified = true
      verifications.each do |key, value|
        verification_outcome_detail << "#{key}...#{value}"
        verified = false if value.eql?(VERIFICATION_FAIL)
      end
      create_preservation_event(PreservationEvent::VALIDATION,
                                verified ? PreservationEvent::SUCCESS : PreservationEvent::FAILURE,
                                verification_outcome_detail,
                                repo_object)
    else
      verifications = nil
    end
    Results.new(repo_object, verified, verifications)
  end
  
  def create_repository_object(dryrun)
    repo_object = model.constantize.new
    repo_object.label = label if label
    batch_object_datastreams.each {|d| repo_object = add_datastream(repo_object, d, dryrun)} if batch_object_datastreams
    batch_object_relationships.each {|r| repo_object = add_relationship(repo_object, r)} if batch_object_relationships
    repo_object.save unless dryrun
    repo_object
  end  

end
