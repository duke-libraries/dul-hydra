FactoryGirl.define do

  factory :message, class: Ddr::Alerts::Message do

    trait :active do
      active true
    end

    trait :inactive do
      active false
    end

  end

end
