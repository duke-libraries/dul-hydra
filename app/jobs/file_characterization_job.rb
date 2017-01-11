class FileCharacterizationJob
  extend AbstractJob

  @queue = :file_characterization

  def self.perform(pid)
    obj = ActiveFedora::Base.find(pid)
    FileCharacterization.call(obj)
  end

end
