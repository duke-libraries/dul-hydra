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

      def show_ds_download_link? ds
        ds.has_content? && can?(:download, ds)
      end

    end
  end
end
