FactoryGirl.define do

  factory :item, :aliases => [:container] do
    title "Test Item"
    sequence(:identifier) { |n| "item%05d" % n }

    trait :member_of_collection do
      collection
    end
    
    trait :has_admin_policy do
      admin_policy { create(:public_read_policy) }
    end

    trait :public_read do
      permissions [{:access => 'read', :type => 'group', :name => 'public'}]
    end

    factory :item_has_part do
      after(:create) { |i| i.parts << FactoryGirl.create(:component) }

      factory :item_has_part_has_apo,                   :traits => [:has_admin_policy]
      factory :item_has_part_public_read,               :traits => [:public_read]
      factory :item_in_collection_has_part_has_apo,     :traits => [:has_admin_policy, :member_of_collection]
      factory :item_in_collection_has_part_public_read, :traits => [:public_read, :member_of_collection]
    end

    factory :item_in_collection,             :traits => [:member_of_collection]
    
    factory :item_has_apo,                   :traits => [:has_admin_policy] do
      factory :item_has_apo_with_components_image1_and_image2 do
        after(:create) do |i|
          i.parts << FactoryGirl.create(:component_has_apo_with_content_image1)
          i.parts << FactoryGirl.create(:component_has_apo_with_content_image2)
        end
      end
      factory :item_has_apo_with_components_image3_and_image4 do
        after(:create) do |i|
          i.parts << FactoryGirl.create(:component_has_apo_with_content_image3)
          i.parts << FactoryGirl.create(:component_has_apo_with_content_image4)
        end
      end
    end
    
    factory :item_public_read,               :traits => [:public_read]
    factory :item_in_collection_has_apo,     :traits => [:member_of_collection, :has_admin_policy]
    factory :item_in_collection_public_read, :traits => [:member_of_collection, :public_read]

  end

end
