class GenerateDefaultStructureJob
  extend AbstractJob

  @queue = :structure

  def self.perform(repo_id, opts={})
    GenerateDefaultStructure.new(repo_id, opts).process
  end

end
