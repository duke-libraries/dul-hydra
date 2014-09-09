FactoryGirl.define do

  factory :item do
    title [ "Test Item" ]
    sequence(:identifier) { |n| [ "item%05d" % n ] }

    trait :member_of_collection do
      collection
    end
    
    trait :has_part do
      children { [ FactoryGirl.create(:component) ] }
    end
  end

end
