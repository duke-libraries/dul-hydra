##
## Subscriptions to ActiveSupport::Notifications instrumentation events
##

# Fixity Checks
ActiveSupport::Notifications.subscribe(Ddr::Notifications::FIXITY_CHECK, Ddr::Events::FixityCheckEvent)

# Virus Checks
ActiveSupport::Notifications.subscribe(Ddr::Notifications::VIRUS_CHECK, Ddr::Events::VirusCheckEvent)

# Creation
ActiveSupport::Notifications.subscribe(Ddr::Notifications::CREATION, Ddr::Events::CreationEvent)

# Update
ActiveSupport::Notifications.subscribe(Ddr::Notifications::UPDATE, Ddr::Events::UpdateEvent)
