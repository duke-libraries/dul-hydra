FactoryGirl.define do
  
  factory :ingest_object, class: DulHydra::BatchIngest::IngestObject do
    
    factory :test_model_ingest_object do
      model "TestFileDatastreams"
      label "Test Model Label"
      metadata [
                  {
                    :datastream_name => DulHydra::Datastreams::DESC_METADATA,
                    :payload => "<dc xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"><dcterms:title>Test Object Title</dcterms:title></dc>",
                    :payload_type => "bytes"
                  },
                  {
                    :datastream_name => DulHydra::Datastreams::DIGITIZATION_GUIDE,
                    :payload => "/tmp/metadata.xls",
                    :payload_type => "uri"
                  }
                ]
    end
    
    factory :bad_model_ingest_object do
      model "BadModel"
    end
    
  end
  
end