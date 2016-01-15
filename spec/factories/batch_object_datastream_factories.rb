FactoryGirl.define do
  factory :batch_object_datastream, :class => Ddr::Batch::BatchObjectDatastream do

    factory :batch_object_add_datastream do
      operation Ddr::Batch::BatchObjectDatastream::OPERATION_ADD

      factory :batch_object_add_desc_metadata_datastream_bytes do
        name Ddr::Datastreams::DESC_METADATA
        payload '_:test <http://purl.org/dc/terms/title> "Test Object Title" .'
        payload_type Ddr::Batch::BatchObjectDatastream::PAYLOAD_TYPE_BYTES
      end

      factory :batch_object_add_desc_metadata_datastream_file do
        name Ddr::Datastreams::DESC_METADATA
        payload "/tmp/qdc-rdf.nt"
        payload_type Ddr::Batch::BatchObjectDatastream::PAYLOAD_TYPE_FILENAME
      end

      factory :batch_object_add_content_datastream do
        name Ddr::Datastreams::CONTENT
        payload File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'id001.tif')
        payload_type Ddr::Batch::BatchObjectDatastream::PAYLOAD_TYPE_FILENAME
        checksum "257fa1025245d2d2a60ae81ac7922ca9581ca314"
        checksum_type Ddr::Datastreams::CHECKSUM_TYPE_SHA1
      end

    end

    factory :batch_object_addupdate_datastream do
      operation Ddr::Batch::BatchObjectDatastream::OPERATION_ADDUPDATE

      factory :batch_object_addupdate_desc_metadata_datastream_file do
        name Ddr::Datastreams::DESC_METADATA
        payload "/tmp/qdc-rdf.nt"
        payload_type Ddr::Batch::BatchObjectDatastream::PAYLOAD_TYPE_FILENAME
      end

    end

  end

end
