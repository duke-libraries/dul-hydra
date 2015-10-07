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

  trait :with_add_desc_metadata_attributes do
    after(:create) do |batch_object|
      FactoryGirl.create(:batch_object_add_desc_metadata_attribute, batch_object: batch_object)
    end
  end

  trait :with_clear_desc_metadata_attribute do
    after(:create) do |batch_object|
      FactoryGirl.create(:batch_object_clear_desc_metadata_attribute, batch_object: batch_object)
    end
  end

  trait :with_clear_all_desc_metadata do
    after(:create) do |batch_object|
      FactoryGirl.create(:batch_object_clear_all_desc_metadata, batch_object: batch_object)
    end
  end

  factory :ingest_batch_object, :class => Ddr::Batch::IngestBatchObject do
    has_identifier
    has_label

    factory :basic_ingest_batch_object do
      has_model
      with_add_content_datastream
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

      factory :generic_ingest_batch_object_with_attributes do
        with_add_desc_metadata_attributes
      end
    end

    factory :target_ingest_batch_object do
      model "Target"
      is_target_for_collection
      with_add_content_datastream
    end
  end

  factory :update_batch_object, :class => Ddr::Batch::UpdateBatchObject do
    has_identifier
    has_label
    has_pid

    factory :basic_update_batch_object do
      has_model
      with_add_desc_metadata_attributes
    end

    factory :basic_update_clear_attribute_batch_object do
      has_model
      with_clear_desc_metadata_attribute
    end

    factory :basic_clear_all_and_add_batch_object do
      has_model
      with_clear_all_desc_metadata
      with_add_desc_metadata_attributes
    end
  end

end
