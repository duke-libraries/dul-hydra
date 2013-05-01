FactoryGirl.define do
  factory :batch_object do
    
    trait :is_ingest_object do
      operation BatchObject::OPERATION_INGEST
    end
    
    trait :is_update_object do
      operation BatchObject::OPERATION_UPDATE
    end

    trait :has_identifier do
      sequence(:identifier) { |n| "test%05d" % n }
    end
    
    trait :has_admin_policy do
      after(:create) do |batch_object|
        FactoryGirl.create(:batch_object_add_admin_policy, :batch_object => batch_object)
      end
    end

    trait :has_label do
      label "Object Label"
    end
    
    trait :has_model do
      model "TestModelOmnibus"
    end
    
    trait :has_parent do
      after(:create) do |batch_object|
        FactoryGirl.create(:batch_object_add_parent, :batch_object => batch_object)
      end
    end
    
    trait :is_target_for_collection do
      model "Target"
      after(:create) do |batch_object|
        FactoryGirl.create(:batch_object_add_target_for_collection, :batch_object => batch_object)
      end
    end
    
    trait :with_add_datastreams do
      after(:create) do |batch_object|
        FactoryGirl.create(:batch_object_add_desc_metadata_datastream, :batch_object => batch_object)
        FactoryGirl.create(:batch_object_add_digitization_guide_datastream, :batch_object => batch_object)
        FactoryGirl.create(:batch_object_add_content_datastream, :batch_object => batch_object)          
      end      
    end
    
    factory :ingest_batch_object, :traits => [:is_ingest_object,
                                              :has_identifier,
                                              :has_admin_policy,
                                              :has_label,
                                              :has_model,
                                              :has_parent,
                                              :with_add_datastreams]
    
    factory :ingest_target_object, :traits => [:is_ingest_object,
                                               :is_target_for_collection,
                                               :has_identifier]
    
  end
end
