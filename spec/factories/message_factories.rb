FactoryGirl.define do

  factory :message, class: Ddr::Alerts::Message do

    trait :active do
      active true
    end

    trait :inactive do
      active false
    end

    trait :ddr do
      contexts { [ FactoryGirl.create(:message_context, :ddr) ] }
    end

    trait :repository do
      contexts { [ FactoryGirl.create(:message_context, :repository) ] }
    end

  end

end