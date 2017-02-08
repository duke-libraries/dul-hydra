ActiveSupport::Notifications.subscribe("update.collection.repo_object", ReindexCollectionContents)
ActiveSupport::Notifications.subscribe("success.batch.batch.ddr", SetDefaultStructuresAfterSuccessfulBatchIngest)
