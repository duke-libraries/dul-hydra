# AdminPolicy does not subclass DulHydra::Models::Base
# b/c Hydra::AdminPolicy provides all the datastreams it needs.
class AdminPolicy < Hydra::AdminPolicy

  include DulHydra::Models::Permissible

  APO_NAMESPACE = "duke-apo"

  # Fedora PID of the default APO object
  DEFAULT_APO_PID = "#{APO_NAMESPACE}:default"

  DEFAULT_APO_LABEL = "Default Admin Policy"

  # Inheritable rights assigned to the default APO
  DEFAULT_APO_INHERITABLE_RIGHTS = [{type: 'group', name: 'public', access: 'read'},
                                    {type: 'group', name: 'repositoryEditor', access: 'edit'}]

  # Permissions to set by default on APO objects, if not specified at initial save time
  # Overrides DulHydra::Models::Permissible::DEFAULT_PERMISSIONS
  DEFAULT_PERMISSIONS = [{type: 'group', name: 'repositoryAdmin', access: 'edit'}]

  # Create the default APO and return it
  def self.create_default_apo!
    apo = AdminPolicy.create(:pid => DEFAULT_APO_PID, :label => DEFAULT_APO_LABEL)
    apo.default_permissions = DEFAULT_APO_INHERITABLE_RIGHTS
    apo.permissions = DEFAULT_PERMISSIONS
    apo.save!
    return apo
  end

  # Return the default APO, creating it if necessary and explicitly requested
  def self.default_apo(create=false)
    begin
      AdminPolicy.find(DEFAULT_APO_PID)
    rescue ActiveFedora::ObjectNotFoundError
      if create
        AdminPolicy.create_default_apo!
      else
        raise
      end
    end
  end

end
