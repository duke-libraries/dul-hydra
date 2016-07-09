class FixityCheckJob
  extend Ddr::Jobs::Job
  extend AbstractJob

  @queue = :fixity

  def self.perform(id)
    obj = ActiveFedora::Base.find(id)
    obj.check_fixity
  end
end
