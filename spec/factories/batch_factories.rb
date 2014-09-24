FactoryGirl.define do
  factory :batch, :class => DulHydra::Batch::Models::Batch do
    name "Batch"
    description "This is a batch of stuff to do."
    user { FactoryGirl.create(:user) }
    
    factory :batch_with_basic_ingest_batch_objects do
      ignore do
        object_count 3
      end
      after(:create) do |batch, evaluator|
        FactoryGirl.create_list(:basic_ingest_batch_object, evaluator.object_count, :batch => batch)
      end
    end

    factory :batch_with_generic_ingest_batch_objects do
      ignore do
        object_count 3
      end
      after(:create) do |batch, evaluator|
        FactoryGirl.create_list(:generic_ingest_batch_object_with_bytes, evaluator.object_count, :batch => batch)
      end
    end

    factory :batch_with_basic_update_batch_object do
      after(:create) do |batch|
        FactoryGirl.create(:basic_update_batch_object, :batch => batch)
      end
    end

  end
end
