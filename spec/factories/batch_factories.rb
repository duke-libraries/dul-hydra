FactoryGirl.define do
  factory :batch do
    name "Batch"
    description "This is a batch of stuff to do."
    
    factory :batch_with_ingest_batch_objects do
      ignore do
        object_count 3
      end
      after(:create) do |batch, evaluator|
        FactoryGirl.create_list(:ingest_batch_object_with_datastreams, evaluator.object_count, :batch => batch)
      end
    end
  end
end
