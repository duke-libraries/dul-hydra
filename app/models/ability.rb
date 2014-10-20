require 'dul_hydra'

class Ability

  include Hydra::PolicyAwareAbility

  def custom_permissions
    action_aliases
    discover_permissions
    export_sets_permissions
    events_permissions
    batches_permissions
    ingest_folders_permissions
    metadata_files_permissions
    attachment_permissions
    children_permissions
    upload_permissions
  end

  def action_aliases
    # read aliases
    alias_action :attachments, :collection_info, :components, :event, :events, :items, :targets, to: :read
    # edit/update aliases
    alias_action :permissions, :default_permissions, to: :update
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
    can :create, ExportSet if authenticated_user?
    can :manage, ExportSet, user: current_user
  end

  def events_permissions
    can :read, Ddr::Events::Event, user: current_user
    can :read, Ddr::Events::Event do |e|
      can? :read, e.pid
    end
  end
  
  def batches_permissions
    can :manage, DulHydra::Batch::Models::Batch, :user_id => current_user.id
    can :manage, DulHydra::Batch::Models::BatchObject do |batch_object|
      can? :manage, batch_object.batch
    end
  end

  def ingest_folders_permissions
    can :create, IngestFolder if IngestFolder.permitted_folders(current_user).present?
    can [:show, :procezz], IngestFolder, user: current_user
  end
  
  def metadata_files_permissions
    can [:show, :procezz], MetadataFile, user: current_user
  end
  
  def download_permissions
    can :download, ActiveFedora::Base do |obj|
      if obj.is_a? Component
        can?(:edit, obj) || (can?(:read, obj) && current_user.has_role?(obj, :downloader))
      else
        can? :read, obj
      end
    end
    can :download, SolrDocument do |doc|
      if doc.active_fedora_model == "Component"
        can?(:edit, doc) || (can?(:read, doc) && current_user.has_role?(doc, :downloader))
      else
        can? :read, doc
      end
    end
    can :download, ActiveFedora::Datastream do |ds|
      if ds.dsid == Ddr::Datastreams::CONTENT and ds.digital_object.original_class == Component
        can?(:edit, ds.pid) || (can?(:read, ds.pid) && current_user.has_role?(solr_doc(ds.pid), :downloader))
      else
        can? :read, ds.pid
      end
    end
  end

  def upload_permissions
    can :upload, Ddr::Models::HasContent do |obj|
      can?(:edit, obj)
    end
  end

  def children_permissions
    can :add_children, Ddr::Models::HasChildren do |obj|
      can?(:edit, obj)
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

  def attachment_permissions
    can :add_attachment, Ddr::Models::HasAttachments do |obj|
      can?(:edit, obj)
    end
  end

  # Mimics Hydra::Ability#test_read + Hydra::PolicyAwareAbility#test_read in one method
  def test_discover(pid)
    Rails.logger.debug("[CANCAN] Checking discover permissions for user: #{current_user.user_key} with groups: #{user_groups.inspect}")
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
      Rails.logger.debug("[CANCAN] -policy- Does the POLICY #{policy_pid} provide DISCOVER permissions for #{current_user.user_key}?")
      group_intersection = user_groups & discover_groups_from_policy(policy_pid)
      result = !group_intersection.empty? || discover_persons_from_policy(policy_pid).include?(current_user.user_key)
      Rails.logger.debug("[CANCAN] -policy- decision: #{result}")
      result
    end
  end 

  # Mimics Hydra::Ability#read_groups
  def discover_groups(pid)
    doc = permissions_doc(pid)
    return [] if doc.nil?
    dg = edit_groups(pid) | read_groups(pid) | (doc[self.class.discover_group_field] || [])
    Rails.logger.debug("[CANCAN] discover_groups: #{dg.inspect}")
    return dg
  end

  # Mimics Hydra::PolicyAwareAbility#read_groups_from_policy
  def discover_groups_from_policy(policy_pid)
    policy_permissions = policy_permissions_doc(policy_pid)
    discover_group_field = Hydra.config[:permissions][:inheritable][:discover][:group]
    dg = edit_groups_from_policy(policy_pid) | read_groups_from_policy(policy_pid) | ((policy_permissions == nil || policy_permissions.fetch(discover_group_field, nil) == nil) ? [] : policy_permissions.fetch(discover_group_field, nil))
    Rails.logger.debug("[CANCAN] -policy- discover_groups: #{dg.inspect}")
    return dg
  end

  # Mimics Hydra::Ability#read_persons
  def discover_persons(pid)
    doc = permissions_doc(pid)
    return [] if doc.nil?
    dp = edit_persons(pid) | read_persons(pid) | (doc[self.class.discover_person_field] || [])
    Rails.logger.debug("[CANCAN] discover_persons: #{dp.inspect}")
    return dp
  end

  def discover_persons_from_policy(policy_pid)
    policy_permissions = policy_permissions_doc(policy_pid)
    discover_individual_field = Hydra.config[:permissions][:inheritable][:discover][:individual]
    dp = edit_persons_from_policy(policy_pid) | read_persons_from_policy(policy_pid) | ((policy_permissions == nil || policy_permissions.fetch(discover_individual_field, nil) == nil) ? [] : policy_permissions.fetch(discover_individual_field, nil))
    Rails.logger.debug("[CANCAN] -policy- discover_persons: #{dp.inspect}")
    return dp
  end

  def self.discover_person_field 
    Hydra.config[:permissions][:discover][:individual]
  end

  def self.discover_group_field
    Hydra.config[:permissions][:discover][:group]
  end

  private

  def authenticated_user?
    current_user.persisted?
  end

  def solr_doc(pid)
    SolrDocument.new(ActiveFedora::SolrService.query("id:\"#{pid}\"", rows: 1).first)
  end

end
