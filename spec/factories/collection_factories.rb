FactoryGirl.define do

  factory :collection do
    title "Test Collection"
    sequence(:identifier) { |n| "coll%05d" % n }

    trait :has_admin_policy do
      admin_policy { create(:public_read_policy) }
    end

    factory :collection_has_item do
      after(:create) { |c| c.items << FactoryGirl.create(:item) }

      factory :collection_has_item_has_apo, :traits => [:has_admin_policy]
    end
    
    factory :collection_has_apo,     :traits => [:has_admin_policy] do
      factory :collection_has_apo_with_items_and_components do
        after(:create) do |c|
          c.items << FactoryGirl.create(:item_has_apo_with_components_image1_and_image2)
          c.items << FactoryGirl.create(:item_has_apo_with_components_image3_and_image4)
        end
      end
    end

    factory :collection_has_target do
      after(:create) { |c| c.targets << FactoryGirl.create(:target) }
      factory :collection_has_target_has_apo, :traits => [:has_admin_policy]
    end
  end

end
