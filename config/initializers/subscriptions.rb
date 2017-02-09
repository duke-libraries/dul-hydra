ActiveSupport::Notifications.subscribe("success.batch.batch.ddr", SetDefaultStructuresAfterSuccessfulBatchIngest)

ActiveSupport::Notifications.subscribe(Ddr::Models::Base::UPDATE) do |*args|
  ReindexCollectionContents.call(*args) if args.last[:model] == "Collection"
end

ActiveSupport::Notifications.subscribe(Ddr::Datastreams::SAVE, FileDigestManager)
ActiveSupport::Notifications.subscribe(Ddr::Datastreams::DELETE, FileDigestManager)
ActiveSupport::Notifications.subscribe(Ddr::Models::Base::DELETE, FileDigestManager)
