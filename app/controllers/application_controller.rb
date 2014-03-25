require 'dul_hydra'

class ApplicationController < ActionController::Base

  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior
  include Hydra::PolicyAwareAccessControlsEnforcement
  include DeviseRemoteUser::ControllerBehavior

  protect_from_forgery

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :group_service
  helper_method :all_permissions
  helper_method :find_models_with_gated_discovery

  rescue_from CanCan::AccessDenied do |exception|
    render :file => "#{Rails.root}/public/403", :formats => [:html], :status => 403, :layout => false
  end

  def current_ability
    current_user ? current_user.ability : Ability.new(nil)
  end

  protected

  # Override Hydra::PolicyAwareAccessControlsEnforcement
  def gated_discovery_filters
    return [] if current_user.superuser?
    super
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:username, :email, :password, :remember_me) }
  end
  
  def find_models_with_gated_discovery(model)
    solr_results = model.find_with_conditions({}, fq: gated_discovery_filters.join(" OR "), rows: 9999)
    ActiveFedora::SolrService.lazy_reify_solr_results(solr_results, load_from_solr: true)
  end

  def group_service
    @group_service ||= DulHydra::Services::RemoteGroupService.new(request.env)
  end

  def all_permissions
    ["discover", "read", "edit"]
  end

  def exclude_unwanted_models(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    unwanted = []
    DulHydra.unwanted_models.each do |model|
      unwanted << "-#{ActiveFedora::SolrService.solr_name(:has_model, :symbol)}:\"info:fedora/afmodel:#{model}\""
    end
    solr_parameters[:fq] << "(#{unwanted.join(' AND ')})"
  end
  
end
