FactoryGirl.define do

  factory :item do
    dc_title [ "Test Item" ]
    sequence(:dc_identifier) { |n| [ "item%05d" % n ] }

    trait :member_of_collection do
      collection
    end

    trait :has_part do
      children { [ FactoryGirl.create(:component) ] }
    end
  end

end
