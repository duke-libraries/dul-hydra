FactoryGirl.define do
  factory :batch_object_relationship, :class => Ddr::Batch::BatchObjectRelationship do

    factory :batch_object_add_relationship do
      operation Ddr::Batch::BatchObjectRelationship::OPERATION_ADD

      factory :batch_object_add_admin_policy do
        name "admin_policy"
        object { create(:collection).id }
        object_type Ddr::Batch::BatchObjectRelationship::OBJECT_TYPE_REPO_ID
      end

      factory :batch_object_add_parent do
        name "parent"
        object { create(:test_parent).id }
        object_type Ddr::Batch::BatchObjectRelationship::OBJECT_TYPE_REPO_ID
      end

      factory :batch_object_add_target_for_collection do
        name "collection"
        object { create(:collection).id }
        object_type Ddr::Batch::BatchObjectRelationship::OBJECT_TYPE_REPO_ID
      end

    end

  end
end
