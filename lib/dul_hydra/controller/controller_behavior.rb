require 'dul_hydra'

module DulHydra::Controller
  module ControllerBehavior
    extend ActiveSupport::Concern

    included do
      protect_from_forgery

      # require authentication by default
      before_filter :authenticate_user!

      # tabs
      class_attribute :tab_methods
      helper_method :current_tabs
      helper_method :group_service

      rescue_from CanCan::AccessDenied do |exception|
        render :file => "#{Rails.root}/public/403", :formats => [:html], :status => 403, :layout => false
      end
    end

    def current_ability
      current_user ? current_user.ability : Ability.new(nil)
    end

    protected

    def group_service
      @group_service ||= DulHydra::Services::RemoteGroupService.new(request.env)
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
      return @current_tabs if @current_tabs
      @current_tabs = Tabs.new(self)
      self.tab_methods.each { |m| @current_tabs << self.send(m) } if self.tab_methods
      @current_tabs
    end

    Tab = Struct.new(:label, :id, :href) do
      def css_id
        "tab_#{id}"
      end
      def partial      
        href ? 'tab_ajax_content' : id
      end
    end

    class Tabs < ActiveSupport::OrderedHash

      attr_reader :active_tab

      def initialize(controller)
        super()
        @active_tab = controller.params[:tab]
      end
      
      def << (tab)
        self[tab.id] = tab if tab
      end

      def active
        active_tab && self.key?(active_tab) ? self[active_tab] : self.default
      end

      def default?(tab)
        tab.id == self.default.id
      end

      def default
        self.first[1]
      end
    end
    
    private
    
    # Cf. https://github.com/plataformatec/devise/wiki/How-To:-Change-the-redirect-path-after-destroying-a-session-i.e.-signing-out
    def after_sign_out_path_for(resource_or_scope)
      "/Shibboleth.sso/Logout?return=https://shib.oit.duke.edu/cgi-bin/logout.pl"
    end

  end
end
