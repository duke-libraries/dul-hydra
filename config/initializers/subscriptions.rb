##
## Subscriptions to ActiveSupport::Notifications instrumentation events
##

# Fixity Checks
ActiveSupport::Notifications.subscribe("fixity_check.dul_hydra") do |*args|
  FixityCheckEvent.from_notification_event ActiveSupport::Notifications::Event.new(*args)
end
