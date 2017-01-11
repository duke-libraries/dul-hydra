class FixityCheckJob
  extend AbstractJob

  @queue = :fixity

  def self.perform(id)
    obj = ActiveFedora::Base.find(id)
    obj.fixity_check
  end

end
