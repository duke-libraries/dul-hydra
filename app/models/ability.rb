class Ability < Ddr::Auth::Ability

  self.ability_logic += [:export_sets_permissions, :batches_permissions, :ingest_folders_permissions, :metadata_files_permissions]

  def export_sets_permissions
    can :create, ExportSet if authenticated_user?
    can :manage, ExportSet, user: current_user
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
    can :create, MetadataFile if current_user.groups.include?(DulHydra.metadata_file_creators_group)
    can [:show, :procezz], MetadataFile, user: current_user
  end

end
