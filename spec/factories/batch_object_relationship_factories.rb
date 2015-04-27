FactoryGirl.define do
  factory :batch_object_relationship, :class => DulHydra::Batch::Models::BatchObjectRelationship do

    factory :batch_object_add_relationship do
      operation DulHydra::Batch::Models::BatchObjectRelationship::OPERATION_ADD

      factory :batch_object_add_admin_policy do
        name "admin_policy"
        object { create(:collection).pid }
        object_type DulHydra::Batch::Models::BatchObjectRelationship::OBJECT_TYPE_PID
      end

      factory :batch_object_add_parent do
        name "parent"
        object { create(:test_parent).pid }
        object_type DulHydra::Batch::Models::BatchObjectRelationship::OBJECT_TYPE_PID
      end

      factory :batch_object_add_target_for_collection do
        name "collection"
        object { create(:collection).pid }
        object_type DulHydra::Batch::Models::BatchObjectRelationship::OBJECT_TYPE_PID
      end

    end

  end
end
