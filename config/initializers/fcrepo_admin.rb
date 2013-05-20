module DulHydra
  class Application < Rails::Application
    config.before_initialize do
      #FcrepoAdmin.read_only = true
      FcrepoAdmin.object_nav_items = [:pid, :bookmark, :summary, :datastreams, :permissions, :associations, :preservation_events, :audit_trail]
    end
  end
end

