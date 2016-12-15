ActiveSupport::Notifications.subscribe("save.collection") do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  ReindexCollectionContents.trigger(event)
end

ActiveSupport::Notifications.subscribe(/^create\.\w+/, PermanentId)
ActiveSupport::Notifications.subscribe(/^deaccession\.\w+/, PermanentId)
ActiveSupport::Notifications.subscribe(/^destroy\.\w+/, PermanentId)
ActiveSupport::Notifications.subscribe(/workflow/, PermanentId)

ActiveSupport::Notifications.subscribe("assign.permanent_id", Ddr::Events::UpdateEvent)
