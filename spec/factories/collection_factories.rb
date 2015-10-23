FactoryGirl.define do

  factory :collection do
    dc_title [ "Test Collection" ]
    sequence(:dc_identifier) { |n| [ "coll%05d" % n ] }

    trait :has_item do
      children { [ FactoryGirl.create(:item) ] }
    end

    trait :has_target do
      targets { [ FactoryGirl.create(:target) ] }
    end
  end

end
