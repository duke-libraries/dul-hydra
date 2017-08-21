class UpdateComponentStructure

  attr_reader :object_id

  def self.call(*args)
    event = ActiveSupport::Notifications::Event.new(*args)
    payload = event.payload
    return false if payload[:skip_structure_updates]
    return false unless Component::STRUCTURALLY_RELEVANT_DATASTREAMS.include?(payload[:file_id])
    return false unless model(payload[:pid]) == 'Component'
    SetDefaultStructure.new(payload[:pid]).enqueue_default_structure_job
  end

  def self.model(repo_id)
    SolrDocument.find(repo_id)[Ddr::Index::Fields::ACTIVE_FEDORA_MODEL]
  rescue Ddr::Models::SolrDocument::NotFound
    nil
  end

end
