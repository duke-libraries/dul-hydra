FactoryGirl.define do
  factory :batch do
    name "Batch"
    description "This is a batch of stuff to do."
#    user { FactoryGirl.create(:reader) }
    
    factory :batch_with_generic_ingest_batch_objects do
      ignore do
        object_count 3
      end
      after(:create) do |batch, evaluator|
        FactoryGirl.create_list(:generic_ingest_batch_object, evaluator.object_count, :batch => batch)
      end
    end
  end
end
