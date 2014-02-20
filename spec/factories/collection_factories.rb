FactoryGirl.define do

  factory :collection do
    title "Test Collection"
    sequence(:identifier) { |n| "coll%05d" % n }
    admin_policy

    factory :collection_has_item do
      after(:create) { |c| c.items << FactoryGirl.create(:item) }
    end
    
    factory :collection_with_items_and_components do
      after(:create) do |c|
        c.items << FactoryGirl.create(:item_has_apo_with_components_image1_and_image2)
        c.items << FactoryGirl.create(:item_has_apo_with_components_image3_and_image4)
      end
    end

    factory :collection_has_target do
      after(:create) { |c| c.targets << FactoryGirl.create(:target) }
    end
  end

end
