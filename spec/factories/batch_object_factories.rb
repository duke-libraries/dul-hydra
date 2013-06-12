FactoryGirl.define do

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
      FactoryGirl.create(:batch_object_add_desc_metadata_datastream_file, :batch_object => batch_object)
      FactoryGirl.create(:batch_object_add_digitization_guide_datastream, :batch_object => batch_object)
      FactoryGirl.create(:batch_object_add_content_datastream, :batch_object => batch_object)          
    end      
  end
      
  factory :ingest_batch_object do
    has_identifier
    has_label
    
    factory :generic_ingest_batch_object do
      has_model
      has_admin_policy
      has_parent
      with_add_datastreams
    end
    
    factory :target_ingest_batch_object do
      model "Target"
      is_target_for_collection
    end
  end
  
end
