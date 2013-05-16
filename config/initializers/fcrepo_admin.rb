module DulHydra
  class Application < Rails::Application
    config.before_initialize do
      logger.debug "Initializing DulHydra ..."
      FcrepoAdmin.object_context_nav_items = [:summary, :datastreams, :permissions, :associations, :preservation_events, :audit_trail]
    end
  end
end

