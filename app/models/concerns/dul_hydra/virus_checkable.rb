module DulHydra
  module VirusCheckable
    extend ActiveSupport::Concern

    included do
      around_save :perform_virus_check, if: "content_changed? && virus_checkable?"
    end

    def virus_checks
      VirusCheckEvent.for_object(self)
    end

    def virus_checkable?
      content.content.respond_to? :path
    end

    protected

    # Callback method
    def perform_virus_check
      event = VirusCheck.execute(self, content.content) # raises DulHydra::VirusFoundError
      yield
      event.pid = pid unless event.pid # pid won't be set before save if new record
      event.save!
    end

  end
end
