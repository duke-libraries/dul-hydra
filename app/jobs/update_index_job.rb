class UpdateIndexJob
  extend AbstractJob

  @queue = :index

  def self.perform(id)
    obj = ActiveFedora::Base.find(id)
    obj.update_index
  end

end
