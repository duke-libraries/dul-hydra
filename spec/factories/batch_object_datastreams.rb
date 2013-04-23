# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :batch_object_datastream do
    
    factory :batch_object_add_datastream do
      operation BatchObjectDatastream::ADD
      
      factory :batch_object_add_desc_metadata_datastream do
        name DulHydra::Datastreams::DESC_METADATA
        payload "<dc xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"><dcterms:title>Test Object Title</dcterms:title></dc>"
        payload_type BatchObjectDatastream::BYTES
      end
      
      factory :batch_object_add_digitization_guide_datastream do
        name DulHydra::Datastreams::DIGITIZATION_GUIDE
        payload File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'metadata.xls')
        payload_type BatchObjectDatastream::FILENAME        
      end

      factory :batch_object_add_content_datastream do
        name DulHydra::Datastreams::CONTENT
        payload File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'id001.tif')
        payload_type BatchObjectDatastream::FILENAME        
      end
    end    
  end
end
