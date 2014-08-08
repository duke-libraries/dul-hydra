##
## Subscriptions to ActiveSupport::Notifications instrumentation events
##

# Fixity Checks
ActiveSupport::Notifications.subscribe(DulHydra::Notifications::FIXITY_CHECK, FixityCheckEvent)

# Virus Checks
ActiveSupport::Notifications.subscribe(DulHydra::Notifications::VIRUS_CHECK, VirusCheckEvent)

# Creation
ActiveSupport::Notifications.subscribe(DulHydra::Notifications::CREATION, CreationEvent)

# Update
ActiveSupport::Notifications.subscribe(DulHydra::Notifications::UPDATE, UpdateEvent)
