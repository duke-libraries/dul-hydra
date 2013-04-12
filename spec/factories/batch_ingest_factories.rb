FactoryGirl.define do
  
  factory :ingest_object, class: DulHydra::BatchIngest::IngestObject do
    sequence(:identifier) { |n| "id%05d" % n }
    
    factory :collection_ingest_object do
      model "Collection"
    end
    
    factory :bad_model_ingest_object do
      model "BadModel"
    end
    
  end
  
end