module DulHydra
  module Notifications
    
    FIXITY_CHECK = "fixity_check.events.dul_hydra"
    VIRUS_CHECK = "virus_check.events.dul_hydra"
    CREATION = "creation.events.dul_hydra"
    UPDATE = "update.events.dul_hydra"

    def self.notify_event(type, args={})
      name = "#{type}.events.dul_hydra"
      ActiveSupport::Notifications.instrument(name, args)
    end

  end
end
