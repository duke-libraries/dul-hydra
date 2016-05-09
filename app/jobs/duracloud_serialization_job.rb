class DuracloudSerializationJob
  @queue = :serialization

  def self.perform(id)
    obj = ActiveFedora::Base.find(id)
    DuracloudSerialization.serialize(obj)
  end
end
