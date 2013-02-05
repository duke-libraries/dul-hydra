FactoryGirl.define do

  factory :collection do
    title "Test Collection"
    sequence(:identifier) { |n| "coll%05d" % n }

    trait :has_admin_policy do
      admin_policy
    end

    factory :collection_has_item do
      after(:create) { |c| c.items << FactoryGirl.create(:item) }

      factory :collection_has_item_has_apo, traits: [:has_admin_policy]

    end

    factory :collection_has_apo, traits: [:has_admin_policy]

  end

end
