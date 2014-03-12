require 'dul_hydra'

class ApplicationController < ActionController::Base

  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior
  include Hydra::PolicyAwareAccessControlsEnforcement
  include DeviseRemoteUser::ControllerBehavior

  protect_from_forgery

  before_filter :authenticate_user!
  before_filter :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_tabs
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

  # Copied from hydra-editor's ResourceControllerBehavior
  def resource_instance_name
    self.class.name.sub("Controller", "").underscore.split('/').last.singularize
  end

  # Copied from hydra-editor's ResourceControllerBehavior
  def get_resource_ivar
    instance_variable_get("@#{resource_instance_name}")
  end

  # Override Hydra::PolicyAwareAccessControlsEnforcement
  def gated_discovery_filters
    return [] if current_user.superuser?
    super
  end

  def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
      devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:username, :email, :password, :remember_me) }
      devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
  end
  
  def find_models_with_gated_discovery(model)
    solr_results = model.find_with_conditions({}, fq: gated_discovery_filters.join(" OR "))
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

  #
  # tabs
  #

  def current_tabs
    return Tabs.new(self) unless self.respond_to?(:tabs)
    @current_tabs ||= self.tabs
  end

  class Tab
    attr_reader :id, :href, :guard, :actions

    def initialize(id, opts={})
      @id = id
      @href = opts[:href]
      @guard = opts.fetch(:guard, true)
      @actions = opts.fetch(:actions, [])
    end

    def authorized_actions
      @authorized_actions ||= actions.select {|a| a.guard}
    end

    def css_id
      "tab_#{id}"
    end

    def partial
      href ? 'tab_ajax_content': id
    end

    def label
      I18n.t("dul_hydra.tabs.#{id}.label")
    end
  end # Tab

  class TabAction
    attr_reader :id, :href, :guard

    def initialize(id, href, guard=true)
      @id = id
      @href = href
      @guard = guard
    end
  end

  class Tabs < ActiveSupport::OrderedHash
    attr_reader :active_tab

    def initialize(controller, *methods)
      super()
      @active_tab = controller.params[:tab]
      methods.each {|m| self << controller.send(m)}
    end
    
    def << (tab)
      self[tab.id] = tab if tab.guard
    end

    def active
      active_tab && self.key?(active_tab) ? self[active_tab] : self.default
    end

    def default?(tab)
      self.default ? tab.id == self.default.id : false
    end

    def default
      self.first[1] unless self.empty?
    end
  end
  
end
