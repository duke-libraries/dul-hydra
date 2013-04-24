FactoryGirl.define do
  factory :batch_object do
    sequence(:identifier) { |n| "test%05d" % n }
    
    factory :ingest_batch_object do
      operation BatchObject::OPERATION_INGEST
      model "TestModelOmnibus"
      label "Test Model Label"
      
      factory :ingest_batch_object_with_datastreams do
        after(:create) do |ingest_batch_object|
          FactoryGirl.create(:batch_object_add_desc_metadata_datastream, :batch_object => ingest_batch_object)
          FactoryGirl.create(:batch_object_add_digitization_guide_datastream, :batch_object => ingest_batch_object)
          FactoryGirl.create(:batch_object_add_content_datastream, :batch_object => ingest_batch_object)          
        end
      end
    end
    
  end
end
