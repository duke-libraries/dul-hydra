FactoryGirl.define do
  factory :batch_object_relationship do
    
    factory :batch_object_add_relationship do
      operation BatchObjectRelationship::OPERATION_ADD
      
      factory :batch_object_add_admin_policy do
        name "admin_policy"
        object { create(:public_read_policy).pid }
        object_type BatchObjectRelationship::OBJECT_TYPE_PID
      end
      
      factory :batch_object_add_parent do
        name "parent"
        object { create(:test_parent).pid }
        object_type BatchObjectRelationship::OBJECT_TYPE_PID
      end

      factory :batch_object_add_target_for_collection do
        name "collection"
        object { create(:collection).pid }
        object_type BatchObjectRelationship::OBJECT_TYPE_PID
      end

    end    

  end
end
