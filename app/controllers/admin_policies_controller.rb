class AdminPoliciesController < ApplicationController
  
  load_and_authorize_resource

  def edit
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
    unless params[:new_group_name].blank? || params[:new_group_perm].blank?
      @admin_policy.default_permissions = [{:name => params[:new_group_name], :access => params[:new_group_perm], :type => 'group'}]
      @admin_policy.save
    end
    @admin_policy.update_attributes(params[:admin_policy])
    flash[:notice] = I18n.t('dul_hydra.admin_policies.messages.updated')
    redirect_to object_path(@admin_policy)
  end
  
end
