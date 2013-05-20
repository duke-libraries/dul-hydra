module DulHydra
  class Application < Rails::Application
    config.before_initialize do
      FcrepoAdmin.read_only = true
      FcrepoAdmin.object_nav_items = [:pid, :summary, :datastreams, :permissions, :children, :associations, :preservation_events, :audit_trail]
    end
  end
end

