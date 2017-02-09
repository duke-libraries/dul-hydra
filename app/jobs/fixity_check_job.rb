class FixityCheckJob
  extend AbstractJob

  @queue = :fixity

  def self.perform(id)
    obj = ActiveFedora::Base.find(id)
    FixityCheck.call(obj)
  end

end
