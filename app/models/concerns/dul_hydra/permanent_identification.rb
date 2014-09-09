module DulHydra
  module PermanentIdentification
    extend ActiveSupport::Concern

    included do
      has_attributes :permanent_id, datastream: DulHydra::Datastreams::PROPERTIES, multiple: false
      after_create :assign_permanent_identifier
    end

    protected

    def assign_permanent_identifier
      reload
      unless permanent_id.present?
        event_args = { pid: self.pid, summary: "Assigned permanent ID" }
        begin
          self.permanent_id = DulHydra::Services::IdService.mint
          save
          event_args[:outcome] = Event::SUCCESS
          event_args[:detail] = "Assigned permanent ID #{self.permanent_id} to #{self.pid}"
        rescue Exception => e
          event_args[:outcome] = Event::FAILURE
          event_args[:detail] = "Unable to assign permanent ID to #{self.pid}"
          Rails.logger.error("Error assigning permanent ID to #{self.pid}: #{e}")
        end
        DulHydra::Notifications.notify_event(:update, event_args)
      end
    end

  end
end