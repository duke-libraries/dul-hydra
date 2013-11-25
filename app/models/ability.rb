require 'dul_hydra'

class Ability

  include Hydra::PolicyAwareAbility
  include FcrepoAdmin::Ability

  self.ability_logic += DulHydra.extra_ability_logic if DulHydra.extra_ability_logic

  def create_permissions
    super # Permits :create for :all if user is authenticated
    # First block repository object creation ...
    cannot :create, ActiveFedora::Base 
    # ... then permit members of authorized groups on a per-model basis
    DulHydra.creatable_models.each do |model|
      grant_by_group(action: :create, subject: model_class(model))
    end
  end

  def read_permissions
    super
    can :read, ActiveFedora::Datastream do |ds|
      can? :read, ds.pid
    end
  end

  def edit_permissions
    super
    can [:edit, :update, :destroy], ActiveFedora::Datastream do |action, ds|
      can? action, ds.pid
    end
  end

  def export_sets_permissions
    can :manage, ExportSet, :user_id => current_user.id
  end

  def preservation_events_permissions
    can :read, PreservationEvent do |pe|
      pe.for_object? and can?(:read, pe.for_object)
    end
  end
  
  def batches_permissions
    can :manage, DulHydra::Batch::Models::Batch, :user_id => current_user.id
  end

  def ingest_folders_permissions
    cannot :create, IngestFolder unless IngestFolder.permitted_folders(current_user).present?
    can [:show, :procezz], IngestFolder, :user => current_user
  end
  
  # Hydra::Ability adds #download_permissions in hydra-head 7.0
  def download_permissions
    can :download, ActiveFedora::Datastream do |ds|
      if ds.dsid == DulHydra::Datastreams::CONTENT and ds.digital_object.original_class == Component
        grant_by_group(action: :download, subject: Component)
      else
        can? :read, ds
      end
    end
  end

  # Mimics Hydra::Ability#read_permissions
  def discover_permissions
    can :discover, String do |pid|
      test_discover(pid)
    end

    can :discover, ActiveFedora::Base do |obj|
      test_discover(obj.pid)
    end 
    
    can :discover, SolrDocument do |obj|
      cache.put(obj.id, obj)
      test_discover(obj.id)
    end 
  end

  # Mimics Hydra::Ability#test_read + Hydra::PolicyAwareAbility#test_read in one method
  def test_discover(pid)
    logger.debug("[CANCAN] Checking discover permissions for user: #{current_user.user_key} with groups: #{user_groups.inspect}")
    group_intersection = user_groups & discover_groups(pid)
    result = !group_intersection.empty? || discover_persons(pid).include?(current_user.user_key)
    result || test_discover_from_policy(pid)
  end 

  # Mimics Hydra::PolicyAwareAbility#test_read_from_policy
  def test_discover_from_policy(object_pid)
    policy_pid = policy_pid_for(object_pid)
    if policy_pid.nil?
      return false
    else
      logger.debug("[CANCAN] -policy- Does the POLICY #{policy_pid} provide DISCOVER permissions for #{current_user.user_key}?")
      group_intersection = user_groups & discover_groups_from_policy(policy_pid)
      result = !group_intersection.empty? || discover_persons_from_policy(policy_pid).include?(current_user.user_key)
      logger.debug("[CANCAN] -policy- decision: #{result}")
      result
    end
  end 

  # Mimics Hydra::Ability#read_groups
  def discover_groups(pid)
    doc = permissions_doc(pid)
    return [] if doc.nil?
    dg = edit_groups(pid) | read_groups(pid) | (doc[self.class.discover_group_field] || [])
    logger.debug("[CANCAN] discover_groups: #{dg.inspect}")
    return dg
  end

  # Mimics Hydra::PolicyAwareAbility#read_groups_from_policy
  def discover_groups_from_policy(policy_pid)
    policy_permissions = policy_permissions_doc(policy_pid)
    discover_group_field = Hydra.config[:permissions][:inheritable][:discover][:group]
    dg = edit_groups_from_policy(policy_pid) | read_groups_from_policy(policy_pid) | ((policy_permissions == nil || policy_permissions.fetch(discover_group_field, nil) == nil) ? [] : policy_permissions.fetch(discover_group_field, nil))
    logger.debug("[CANCAN] -policy- discover_groups: #{dg.inspect}")
    return dg
  end

  # Mimics Hydra::Ability#read_persons
  def discover_persons(pid)
    doc = permissions_doc(pid)
    return [] if doc.nil?
    dp = edit_persons(pid) | read_persons(pid) | (doc[self.class.discover_person_field] || [])
    logger.debug("[CANCAN] discover_persons: #{dp.inspect}")
    return dp
  end

  def discover_persons_from_policy(policy_pid)
    policy_permissions = policy_permissions_doc(policy_pid)
    discover_individual_field = Hydra.config[:permissions][:inheritable][:discover][:individual]
    dp = edit_persons_from_policy(policy_pid) | read_persons_from_policy(policy_pid) | ((policy_permissions == nil || policy_permissions.fetch(discover_individual_field, nil) == nil) ? [] : policy_permissions.fetch(discover_individual_field, nil))
    logger.debug("[CANCAN] -policy- discover_persons: #{dp.inspect}")
    return dp
  end

  def self.discover_person_field 
    Hydra.config[:permissions][:discover][:individual]
  end

  def self.discover_group_field
    Hydra.config[:permissions][:discover][:group]
  end

  def can_create_models
    DulHydra.creatable_models.select { |model| can_create_model? model }
  end

  def can_create_model?(model)
    can? :create, model_class(model)
  end

  def can_create_models?
    can_create_models.present?
  end

  protected

  def grant_by_group(args)
    can args[:action], args[:subject] if current_user.member_of?(ability_group(args))
  end

  def ability_group(args)
    model_s = args[:subject].to_s
    return unless DulHydra.ability_group_map.key?(model_s)
    DulHydra.ability_group_map[model_s][args[:action]]
  end
  
  private

  def model_class(model)
    model.respond_to?(:constantize) ? model.constantize : model
  end

end
