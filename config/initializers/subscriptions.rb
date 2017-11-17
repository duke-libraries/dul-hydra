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

# Structural metadata creation and maintenance subscriptions
ActiveSupport::Notifications.subscribe("success.batch.batch.ddr", SetDefaultStructuresAfterSuccessfulBatchIngest)
ActiveSupport::Notifications.subscribe(Ddr::Models::Base::INGEST) do |*args|
  SetDefaultStructure.call(*args) if [ "Collection", "Item", "Component" ].include?(args.last[:model])
  UpdateParentStructure.call(*args) if [ "Item", "Component" ].include?(args.last[:model])
end
ActiveSupport::Notifications.subscribe(Ddr::Models::Base::UPDATE) do |*args|
  UpdateComponentStructure.call(*args) if args.last[:model] == "Component"
end
ActiveSupport::Notifications.subscribe(Ddr::Models::Base::DELETE) do |*args|
  UpdateParentStructure.call(*args) if [ "Item", "Component" ].include?(args.last[:model])
end

ActiveSupport::Notifications.subscribe(Ddr::Datastreams::SAVE) do |*args|
  if args.last[:file_id] == Ddr::Datastreams::FITS
    UpdateContentMediaType.call(*args)
  end
end
