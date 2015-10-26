module DulHydra
  module Scripts
    extend ActiveSupport::Autoload

    autoload :CreatePendingBatchScript
    autoload :CsvToXml
    autoload :IngestFolderProcessor
    autoload :ProcessMETSFolder
    autoload :ProcessSimpleIngest
    autoload :Thumbnails

  end
end
