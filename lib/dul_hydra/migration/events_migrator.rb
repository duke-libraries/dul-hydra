module DulHydra::Migration
  class EventsMigrator < Migrator

    # source: Rubydora::DigitalObject
    # target: ActiveFedora::Base

    def migrate
      events = Ddr::Events::Event.for_pid(source.pid)
      events.each do |e|
        e.pid = target.id
        e.save!
      end
    end

  end
end
