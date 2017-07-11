ActiveSupport::Notifications.subscribe("success.batch.batch.ddr", SetDefaultStructuresAfterSuccessfulBatchIngest)

ActiveSupport::Notifications.subscribe(Ddr::Models::Base::UPDATE) do |*args|
  ReindexCollectionContents.call(*args) if args.last[:model] == "Collection"
end

ActiveSupport::Notifications.subscribe(Ddr::Datastreams::SAVE, FileDigestManager)
ActiveSupport::Notifications.subscribe(Ddr::Datastreams::DELETE, FileDigestManager)
ActiveSupport::Notifications.subscribe(Ddr::Models::Base::DELETE, FileDigestManager)

ActiveSupport::Notifications.subscribe(Ddr::Models::Base::DELETE, DeletedObject)
ActiveSupport::Notifications.subscribe(Ddr::Datastreams::DELETE, DeletedDatastream)

ActiveSupport::Notifications.subscribe(DatastreamUpload::FINISHED, MonitorDatastreamUpload)
ActiveSupport::Notifications.subscribe(NestedFolderIngest::FINISHED, MonitorNestedFolderIngest)
ActiveSupport::Notifications.subscribe(StandardIngest::FINISHED, MonitorStandardIngest)
