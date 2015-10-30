require 'dul_hydra'

class ApplicationController < ActionController::Base

  include Blacklight::Controller
  include Ddr::Auth::RoleBasedAccessControlsEnforcement

  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

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

end
