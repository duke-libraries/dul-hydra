require 'dul_hydra'

module DulHydra::Controller
  module ControllerBehavior
    extend ActiveSupport::Concern

    included do
      protect_from_forgery

      # require authentication by default
      before_filter :authenticate_user!

      # tabs
      helper_method :current_tabs
      helper_method :group_service
      helper_method :all_permissions

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
      return unless self.respond_to?(:tabs)
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
        return 'tab_ajax_content' if href
        if ["items", "components"].include?(id)
          'children'
        else
          id
        end
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
