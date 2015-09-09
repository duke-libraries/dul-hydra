FactoryGirl.define do
  factory :batch_object_attribute, :class => Ddr::Batch::BatchObjectAttribute do

    factory :batch_object_add_attribute do
      operation Ddr::Batch::BatchObjectAttribute::OPERATION_ADD

      factory :batch_object_add_desc_metadata_attribute do
        datastream Ddr::Datastreams::DESC_METADATA
        name 'title'
        value 'Test Object Title'
        value_type Ddr::Batch::BatchObjectAttribute::VALUE_TYPE_STRING
      end

    end

    factory :batch_object_clear_attribute do
      operation Ddr::Batch::BatchObjectAttribute::OPERATION_CLEAR

      factory :batch_object_clear_desc_metadata_attribute do
        datastream Ddr::Datastreams::DESC_METADATA
        name 'title'
      end
    end

    factory :batch_object_clear_all_attribute do
      operation Ddr::Batch::BatchObjectAttribute::OPERATION_CLEAR_ALL

      factory :batch_object_clear_all_desc_metadata do
        datastream Ddr::Datastreams::DESC_METADATA
      end
    end

  end
end
