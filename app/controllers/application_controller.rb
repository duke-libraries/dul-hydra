require 'dul_hydra'

class ApplicationController < ActionController::Base

  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior
  include Hydra::PolicyAwareAccessControlsEnforcement
  include DulHydra::Grouper::Controller

  before_filter :authenticate_user!
  
  rescue_from CanCan::AccessDenied do |exception|
    render :file => "#{Rails.root}/public/403", :formats => [:html], :status => 403, :layout => false
  end

  protect_from_forgery

  def current_ability
    current_user ? current_user.ability(session) : Ability.new(nil)
  end

  protected

  def exclude_unwanted_models(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    unwanted = []
    DulHydra.unwanted_models.each do |model|
      unwanted << "-#{ActiveFedora::SolrService.solr_name(:has_model, :symbol)}:\"info:fedora/afmodel:#{model}\""
    end
    solr_parameters[:fq] << "(#{unwanted.join(' AND ')})"
  end

  def configure_tabs(*tabs)
    @tabs = Tabs.new(self, *tabs)
  end

  Tab = Struct.new(:label, :id, :href) do
    def css_id
      "tab_#{id}"
    end
    def partial      
      href ? 'tab_ajax_content' : id
    end
  end

  class Tabs
    include Enumerable

    def initialize(controller, *tab_symbols)
      @tabs = tab_symbols.collect {|t| controller.send("tab_#{t}") }.reject { |t| t.blank? }
    end

    def each
      @tabs.each { |t| yield t }
    end
  end
  
  private
  
  # Cf. https://github.com/plataformatec/devise/wiki/How-To:-Change-the-redirect-path-after-destroying-a-session-i.e.-signing-out
  def after_sign_out_path_for(resource_or_scope)
    "/Shibboleth.sso/Logout?return=https://shib.oit.duke.edu/cgi-bin/logout.pl"
  end
  
end
