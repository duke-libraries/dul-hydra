FactoryGirl.define do

  factory :item, aliases: [:container] do
    title "Test Item"
    sequence(:identifier) { |n| "item%05d" % n }

    trait :member_of_collection do
      collection
    end
    
    trait :has_admin_policy do
      admin_policy
    end

    factory :item_has_part do
      after(:create) { |i| i.parts << FactoryGirl.create(:component) }

      factory :item_has_part_has_apo,               traits: [:has_admin_policy]
      factory :item_in_collection_has_part_has_apo, traits: [:has_admin_policy, :member_of_collection]

    end

    factory :item_in_collection,         traits: [:member_of_collection]
    factory :item_has_apo,               traits: [:has_admin_policy]
    factory :item_in_collection_has_apo, traits: [:member_of_collection, :has_admin_policy]

  end

end
