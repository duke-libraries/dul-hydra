class VersionCreationJob
  extend Ddr::Jobs::Job
  @queue = :versioning

  def self.perform(id)
    obj = ActiveFedora::Base.find(id)
    obj.create_version
  end

end
