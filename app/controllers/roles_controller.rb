class RolesController < ApplicationController

  # before_action :normalize_groups, only: [:create, :update]

  before_action only: :create do
    @role = Role.new(role_attributes)
  end

  load_and_authorize_resource

  layout 'roles'

  def index
  end

  def new
  end

  def create
    if @role.save
      flash[:success] = I18n.t('dul_hydra.roles.alerts.created')
      redirect_to @role
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    @role.attributes = role_attributes
    if @role.save
      flash[:success] = I18n.t('dul_hydra.roles.alerts.updated')
      redirect_to @role
    else
      render :edit
    end
  end

  def destroy
    @role.destroy
    if @role.destroyed?
      flash[:success] = I18n.t('dul_hydra.roles.alerts.deleted', role_name: @role.name)
      redirect_to roles_path
    else
      flash.now[:error] = I18n.t('dul_hydra.roles.alerts.delete_failed')
      render :show
    end
  end

  protected

  def role_attributes
    params.require(:role).permit(:name, :model, :ability, :groups, :user_ids => [])
  end

  def normalize_groups
    groups = params[:role][:groups].split 
    params[:role][:groups] = groups.empty? ? nil : groups
  end

end
