ActiveSupport::Notifications.subscribe("save.collection") do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  ReindexCollectionContents.trigger(event)
end

ActiveSupport::Notifications.subscribe(/create\.\w+/) do |*args|
  if DulHydra.auto_assign_permanent_id
    event = ActiveSupport::Notifications::Event.new(*args)
    AssignPermanentId.call(event.payload[:pid])
  end
end
