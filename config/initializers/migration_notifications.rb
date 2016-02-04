ActiveSupport::Notifications.subscribe 'migration_timer' do |name, start, finish, id, payload|
  report = DulHydra::Migration::MigrationReport.find_or_create_by(fcrepo3_pid: payload[:pid])
  timr = DulHydra::Migration::MigrationTimer.new.tap do |tmr|
    tmr.migration_report = report
    tmr.event = payload[:event]
    tmr.duration = finish - start
  end
  timr.save
end
