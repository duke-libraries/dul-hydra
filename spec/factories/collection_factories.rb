FactoryGirl.define do

  factory :collection do
    title [ "Test Collection" ]
    sequence(:identifier) { |n| [ "coll%05d" % n ] }

    trait :has_item do
      children { [ FactoryGirl.create(:item) ] }
    end
    
    trait :has_target do
      targets { [ FactoryGirl.create(:target) ] }
    end
  end

end
