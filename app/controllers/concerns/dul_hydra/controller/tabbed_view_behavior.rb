module DulHydra
  module Controller
    module TabbedViewBehavior
      extend ActiveSupport::Concern

      included do
        helper_method :current_tabs
        class_attribute :tabs
      end

      protected

      def current_tabs
        @current_tabs ||= Tabs.new(self)
      end

      def datastream_download_url_for dsid
        url_for controller: "downloads", action: "show", id: current_object, datastream_id: dsid
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

        def initialize(controller)
          super()
          @active_tab = controller.params[:tab]
          controller.tabs.each {|m| self << controller.send(m)} if controller.tabs.present?
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
      
      #
      # tab methods
      #

      def tab_children(id)
        Tab.new(id, guard: current_object.has_children?)
      end

      def tab_items
        tab_children("items")
      end

      def tab_components
        tab_children("components")
      end

      def tab_descriptive_metadata
        Tab.new("descriptive_metadata",
                actions: [
                          TabAction.new("edit",
                                        url_for(action: "edit"),
                                        can?(:edit, current_object)),
                          TabAction.new("download",
                                        datastream_download_url_for("descMetadata"),
                                        can?(:download, current_object.descMetadata))
                         ]
                )
      end

      def tab_default_permissions
        Tab.new("default_permissions",
                actions: [
                          TabAction.new("edit", 
                                        url_for(action: "default_permissions"),
                                        can?(:edit, current_object)),
                          TabAction.new("download",
                                        datastream_download_url_for("defaultRights"),
                                        can?(:download, current_object.defaultRights))
                         ]
                )
      end

      def tab_permissions
        Tab.new("permissions",
                actions: [
                          TabAction.new("edit", 
                                        url_for(action: "permissions"),
                                        can?(:edit, current_object)),
                          TabAction.new("download",
                                        datastream_download_url_for("rightsMetadata"),
                                        can?(:download, current_object.rightsMetadata))
                         ]
                )
      end

      def tab_preservation_events
        Tab.new("preservation_events", 
                href: url_for(action: "preservation_events"),
                guard: current_object.has_preservation_events?)
      end

      def tab_attachments
        Tab.new("attachments", guard: current_object.has_attachments?)
      end

      def tab_collection_info
        Tab.new("collection_info", 
                href: url_for(action: "collection_info")
                )
      end

    end
  end
end
