require 'dul_hydra'

class ApplicationController < ActionController::Base

  # XXX This collection of modules may be wrong for hydra-head 9.x
  include Blacklight::Controller
  include Blacklight::Base
  include Hydra::Controller::ControllerBehavior
  include Hydra::AccessControlsEnforcement
  include Ddr::Auth::RoleBasedAccessControlsEnforcement

  # This applies appropriate access controls to all Blacklight solr queries
  self.solr_search_params_logic += [:add_access_controls_to_solr_params]

  protect_from_forgery

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :group_service
  helper_method :all_permissions
  helper_method :find_models_with_gated_discovery
  helper_method :acting_as_superuser?

  rescue_from CanCan::AccessDenied do |exception|
    render file: "#{Rails.root}/public/403", formats: [:html], status: 403, layout: false
  end

  protected

  def acting_as_superuser?
    signed_in?(:superuser)
  end

  def gated_discovery_filters
    return [] if acting_as_superuser?
    super
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:username, :email, :password, :remember_me) }
  end

  def find_models_with_gated_discovery(model, opts={})
    solr_opts = {
      q: "#{Ddr::Index::Fieldss::ACTIVE_FEDORA_MODEL}:\"#{model.name}\"",
      fq: gated_discovery_filters.join(" OR "),
      sort: "#{Ddr::Index::Fieldss::TITLE} ASC",
      rows: 9999
    }
    solr_opts.merge! opts
    solr_response = query_solr(solr_opts)
    solr_results = solr_response.docs
    ActiveFedora::SolrService.lazy_reify_solr_results(solr_results, load_from_solr: true)
  end

  def add_access_controls_to_solr_params(request_params, solr_params)
    apply_gated_discovery(solr_params)
  end

  def all_permissions
    warn "[DEPRECATION] `all_permissions` is deprecated and should not be used with role-based access control."
    # IMPORTANT - rights controller behavior depends on the permissions being
    # ordered from lowest to highest so that assignment of multiple permissions
    # to a user or group results in the highest permission being granted.
    # No doubt this is really terrible, but there it is.
    ["discover", "read", "edit"]
  end

end
