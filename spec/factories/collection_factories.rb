FactoryGirl.define do

  factory :collection do
    title "Test Collection"
    sequence(:identifier) { |n| "coll%05d" % n }

    trait :has_admin_policy do
      admin_policy { create(:public_read_policy) }
    end

    trait :public_read do
      permissions [{:access => 'read', :type => 'group', :name => 'public'}]
    end

    factory :collection_has_item do
      after(:create) { |c| c.items << FactoryGirl.create(:item) }

      factory :collection_has_item_has_apo,     :traits => [:has_admin_policy]
      factory :collection_has_item_public_read, :traits => [:public_read]
    end

    factory :collection_has_apo,     :traits => [:has_admin_policy]
    factory :collection_public_read, :traits => [:public_read]

  end

end
