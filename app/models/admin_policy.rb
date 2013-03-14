#
# AdminPolicy does not subclass DulHydra::Models::Base
# b/c Hydra::AdminPolicy provides all the datastreams it needs.
#
class AdminPolicy < Hydra::AdminPolicy

  APO_NAMESPACE = "duke-apo"

  def self.create_pid(suffix)
    "#{APO_NAMESPACE}:#{suffix}"
  end

end
