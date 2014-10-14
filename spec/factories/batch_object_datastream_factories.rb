FactoryGirl.define do
  factory :batch_object_datastream, :class => DulHydra::Batch::Models::BatchObjectDatastream do
    
    factory :batch_object_add_datastream do
      operation DulHydra::Batch::Models::BatchObjectDatastream::OPERATION_ADD
      
      factory :batch_object_add_desc_metadata_datastream_bytes do
        name Ddr::Datastreams::DESC_METADATA
        payload '_:test <http://purl.org/dc/terms/title> "Test Object Title" .'
        payload_type DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_BYTES
      end
      
      factory :batch_object_add_desc_metadata_datastream_file do
        name Ddr::Datastreams::DESC_METADATA
        payload "/tmp/qdc-rdf.nt"
        payload_type DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_FILENAME
      end

      factory :batch_object_add_content_datastream do
        name Ddr::Datastreams::CONTENT
        payload File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'id001.tif')
        payload_type DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_FILENAME
        checksum "120ad0814f207c45d968b05f7435034ecfee8ac1a0958cd984a070dad31f66f3"
        checksum_type Ddr::Datastreams::CHECKSUM_TYPE_SHA256
      end
      
    end
  
    factory :batch_object_addupdate_datastream do
      operation DulHydra::Batch::Models::BatchObjectDatastream::OPERATION_ADDUPDATE

      factory :batch_object_addupdate_desc_metadata_datastream_file do
        name Ddr::Datastreams::DESC_METADATA
        payload "/tmp/qdc-rdf.nt"
        payload_type DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_FILENAME
      end

    end

  end  
  
end
