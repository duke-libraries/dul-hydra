require 'dul_hydra'

module DulHydra::Controller
  module ControllerBehavior
    extend ActiveSupport::Concern

    included do
      protect_from_forgery
      before_filter :authenticate_user!
      rescue_from CanCan::AccessDenied do |exception|
        render :file => "#{Rails.root}/public/403", :formats => [:html], :status => 403, :layout => false
      end
    end

    def current_ability
      current_user ? current_user.ability : Ability.new(nil)
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

    class Tabs < ActiveSupport::OrderedHash

      attr_reader :controller

      def initialize(controller, *tab_symbols)
        super()
        @controller = controller
        tab_symbols.each do |t| 
          tab = controller.send("tab_#{t}")
          self[tab.id] = tab unless tab.blank?
        end
      end
      
      def active
        tab_param = controller.params[:tab]
        tab_param && self.key?(tab_param) ? self[tab_param] : self.default
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
