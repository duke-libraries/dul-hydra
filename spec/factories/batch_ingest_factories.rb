FactoryGirl.define do
  
  factory :ingest_object, class: DulHydra::BatchIngest::IngestObject do
    
    factory :test_model_ingest_object do
      model "TestFileDatastreams"
      label "Test Model Label"
      data [
              {
                :datastream_name => DulHydra::Datastreams::DESC_METADATA,
                :payload => "<dc xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"><dcterms:title>Test Object Title</dcterms:title></dc>",
                :payload_type => "bytes"
              },
              {
                :datastream_name => DulHydra::Datastreams::DIGITIZATION_GUIDE,
                :payload => File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'metadata.xls'),
                :payload_type => "filename"
              },
              {
                :datastream_name => DulHydra::Datastreams::CONTENT,
                :payload => File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'id001.tif'),
                :payload_type => "filename"
              }
            ]
    end
    
    factory :test_child_ingest_object do
      model "TestChild"
    end
    
  end
  
end