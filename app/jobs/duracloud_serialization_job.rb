class DuracloudSerializationJob
  @queue = :serialization

  def self.perform(id)
    obj = ActiveFedora::Base.find(id)
    serialization = DuracloudSerialization.new(obj)
    serialization.call
  end
end
