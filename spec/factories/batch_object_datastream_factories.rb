FactoryGirl.define do
  factory :batch_object_datastream, :class => DulHydra::Batch::Models::BatchObjectDatastream do
    
    factory :batch_object_add_datastream do
      operation DulHydra::Batch::Models::BatchObjectDatastream::OPERATION_ADD
      
      factory :batch_object_add_desc_metadata_datastream_bytes do
        name DulHydra::Datastreams::DESC_METADATA
        payload "<dc xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"><dcterms:title>Test Object Title</dcterms:title></dc>"
        payload_type DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_BYTES
      end
      
      factory :batch_object_add_desc_metadata_datastream_file do
        name DulHydra::Datastreams::DESC_METADATA
        payload File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'qdc.xml')
        payload_type DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_FILENAME
      end

      factory :batch_object_add_content_datastream do
        name DulHydra::Datastreams::CONTENT
        payload File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'id001.tif')
        payload_type DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_FILENAME
        checksum "120ad0814f207c45d968b05f7435034ecfee8ac1a0958cd984a070dad31f66f3"
        checksum_type DulHydra::Datastreams::CHECKSUM_TYPE_SHA256
      end
      
    end
  
  end
end
