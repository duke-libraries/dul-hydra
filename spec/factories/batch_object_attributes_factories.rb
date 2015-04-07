FactoryGirl.define do
  factory :batch_object_attribute, :class => DulHydra::Batch::Models::BatchObjectAttribute do

    factory :batch_object_add_attribute do
      operation DulHydra::Batch::Models::BatchObjectAttribute::OPERATION_ADD

      factory :batch_object_add_desc_metadata_attribute do
        datastream Ddr::Datastreams::DESC_METADATA
        name 'title'
        value 'Test Object Title'
        value_type DulHydra::Batch::Models::BatchObjectAttribute::VALUE_TYPE_STRING
      end

    end

    factory :batch_object_clear_all_attribute do
      operation DulHydra::Batch::Models::BatchObjectAttribute::OPERATION_CLEAR_ALL

      factory :batch_object_clear_all_desc_metadata do
        datastream Ddr::Datastreams::DESC_METADATA
      end
    end

  end
end