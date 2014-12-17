FactoryGirl.define do

  factory :message_context, class: Ddr::Alerts::MessageContext do

    trait :ddr do
      context Ddr::Alerts::MessageContext::CONTEXT_DDR
    end

    trait :repository do
      context Ddr::Alerts::MessageContext::CONTEXT_REPOSITORY
    end

  end

end