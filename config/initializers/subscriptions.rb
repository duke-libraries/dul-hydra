ActiveSupport::Notifications.subscribe("save.collection") do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  ReindexCollectionContents.trigger(event)
end

ActiveSupport::Notifications.subscribe(/create\.\w+/) do |*args|
  if DulHydra.auto_assign_permanent_id
    event = ActiveSupport::Notifications::Event.new(*args)
    PermanentId.assign!(event.payload[:pid])
  end
end

ActiveSupport::Notifications.subscribe(/workflow/) do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  PermanentId.update!(event.payload[:pid])
end
