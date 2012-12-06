# AdminPolicy does not subclass DulHydra::Models::Base
# b/c Hydra::AdminPolicy provides all the datastreams it needs.
class AdminPolicy < Hydra::AdminPolicy
  extend ActiveSupport::Concern

  include DulHydra::Models::Governable

  #before_save :set_default_permissions

  APO_NAMESPACE = "duke-apo"
  # Fedora PID of the default APO object
  DEFAULT_APO_PID = "#{APO_NAMESPACE}:default"
  # Inheritable rights assigned to the default APO
  DEFAULT_APO_INHERITABLE_RIGHTS = [{type: 'group', name: 'public', access: 'read'},
                                    {type: 'group', name: 'repositoryEditor', access: 'edit'}]
  # Permissions to set by default on APO objects, if not specified at initial save time
  DEFAULT_PERMISSIONS = [{type: 'group', name: 'repositoryAdmin', access: 'edit'}]

  # Create the default APO and return it
  def self.create_default_apo!
    apo = AdminPolicy.create(:pid => DEFAULT_APO_PID)
    apo.default_permissions = DEFAULT_APO_INHERITABLE_RIGHTS
    apo.permissions = DEFAULT_PERMISSIONS
    apo.save
    return apo
  end

  # Return the default APO, creating it if necessary
  def self.default_apo
    begin
      AdminPolicy.find(DEFAULT_APO_PID)
    rescue ActiveFedora::ObjectNotFoundError
      AdminPolicy.create_default_apo!
    end
  end

  protected

  def set_default_permissions
    if self.new_object? && self.permissions.empty?
      self.permissions = DEFAULT_PERMISSIONS
    end
  end

end
