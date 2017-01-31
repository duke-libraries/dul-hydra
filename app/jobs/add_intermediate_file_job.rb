class AddIntermediateFileJob
  extend AbstractJob

  @queue = :batch

  def self.perform(args)
    AddIntermediateFile.new(args).process
  end

end
