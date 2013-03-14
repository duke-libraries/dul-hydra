#
# AdminPolicy does not subclass DulHydra::Models::Base
# b/c Hydra::AdminPolicy provides all the datastreams it needs.
#
class AdminPolicy < Hydra::AdminPolicy

  delegate :default_license_title, :to => 'defaultRights', :at => [:license, :title], :unique => true
  delegate :default_license_description, :to => 'defaultRights', :at => [:license, :description], :unique => true
  delegate :default_license_url, :to => 'defaultRights', :at => [:license, :url], :unique => true

  APO_NAMESPACE = "duke-apo"

  def self.create_pid(suffix)
    "#{APO_NAMESPACE}:#{suffix}"
  end

end
