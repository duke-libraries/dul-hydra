ActiveSupport::Notifications.subscribe 'migration_timer' do |name, start, finish, id, payload|
  report = DulHydra::Migration::MigrationReport.find(payload[:rept_id])
  timr = DulHydra::Migration::MigrationTimer.new.tap do |tmr|
    tmr.migration_report = report
    tmr.event = payload[:event]
    tmr.duration = finish - start
  end
  timr.save
end

ActiveSupport::Notifications.subscribe Ddr::Notifications::MIGRATION, Ddr::Events::MigrationEvent
