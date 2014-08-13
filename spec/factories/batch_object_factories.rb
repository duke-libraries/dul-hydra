FactoryGirl.define do
  
  trait :has_batch do
    after(:create) do |batch_object|
      batch_object.batch = FactoryGirl.create(:batch)
    end
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
  
  trait :has_pid do
    sequence(:pid) { |n| "test:%d" % n }
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
  
  trait :with_add_content_datastream do
    after(:create) do |batch_object|
      FactoryGirl.create(:batch_object_add_content_datastream, :batch_object => batch_object)          
    end      
  end

  trait :with_add_desc_metadata_datastream_bytes do
    after(:create) do |batch_object|
      FactoryGirl.create(:batch_object_add_desc_metadata_datastream_bytes, :batch_object => batch_object)
    end      
  end

  trait :with_add_desc_metadata_datastream_file do
    after(:create) do |batch_object|
      FactoryGirl.create(:batch_object_add_desc_metadata_datastream_file, :batch_object => batch_object)
    end      
  end

  trait :with_addupdate_desc_metadata_datastream do
    after(:create) do |batch_object|
      FactoryGirl.create(:batch_object_addupdate_desc_metadata_datastream_file, :batch_object => batch_object)
    end
  end
  
  factory :ingest_batch_object, :class => DulHydra::Batch::Models::IngestBatchObject do
    has_identifier
    has_label
    
    factory :basic_ingest_batch_object do
      has_model
    end
    
    factory :generic_ingest_batch_object do
      has_model
      has_admin_policy
      has_parent
      with_add_content_datastream
      
      factory :generic_ingest_batch_object_with_bytes do
        with_add_desc_metadata_datastream_bytes
      end
      
      factory :generic_ingest_batch_object_with_file do
        with_add_desc_metadata_datastream_file
      end

    end
    

    factory :target_ingest_batch_object do
      model "Target"
      is_target_for_collection
    end
  end
  
  factory :update_batch_object, :class => DulHydra::Batch::Models::UpdateBatchObject do
    has_identifier
    has_label
    has_pid
    
    factory :basic_update_batch_object do
      has_model
      with_addupdate_desc_metadata_datastream
    end
    
  end
  
end
