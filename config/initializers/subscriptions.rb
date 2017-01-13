ActiveSupport::Notifications.subscribe("save.collection") do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  ReindexCollectionContents.trigger(event)
end
