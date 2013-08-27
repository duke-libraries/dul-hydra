class AdminPoliciesController < ApplicationController
  
  load_and_authorize_resource

  def edit
    existing_groups = []
    default_permissions = @admin_policy.default_permissions
    default_permissions.each do |perm|
      existing_groups << [ perm[:name] ]
    end
    all_groups = [["public"],["registered"],["repositoryReader"],["repositoryEditor"],["repositoryAdmin"],["componentaccess"]]
    @add_groups = all_groups - existing_groups
    @permissions = [['discover'],['read'],['edit']]
    @existing_permissions = @permissions + [["**Remove**", "_remove_"]]
  end
  
  def update
    @admin_policy.defaultRights.clear_permissions!
    unless params[:perm].blank?
      params[:perm].keys.each do |key|
        unless params[:perm][key] == "_remove_"
          @admin_policy.default_permissions = [{:name => key, :access => params[:perm][key], :type => 'group'}]
        end
      end
    end
    @admin_policy.save
    unless params[:new_group_name].blank?
      @admin_policy.default_permissions = [{:name => params[:new_group_name], :access => params[:new_group_perm], :type => 'group'}]
      @admin_policy.save
    end
    @admin_policy.update_attributes(params[:admin_policy])
    flash[:notice] = "Admin Policy updated."
    redirect_to catalog_path(@admin_policy)
  end
  
end