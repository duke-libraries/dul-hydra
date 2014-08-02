##
## Subscriptions to ActiveSupport::Notifications instrumentation events
##

# Fixity Checks
ActiveSupport::Notifications.subscribe(DulHydra::Notifications::FIXITY_CHECK, FixityCheckEvent)

# Virus Checks
ActiveSupport::Notifications.subscribe(DulHydra::Notifications::VIRUS_CHECK, VirusCheckEvent)
