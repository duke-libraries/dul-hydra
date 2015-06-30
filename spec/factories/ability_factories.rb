FactoryGirl.define do

  factory :ability do
    association :auth_context, factory: :auth_context, strategy: :build

    initialize_with { new(auth_context) }

    trait :anonymous do
      association :auth_context, :anonymous, factory: :auth_context, strategy: :build
    end

    trait :duke do
      association :auth_context, :duke, factory: :auth_context, strategy: :build
    end

    factory :abstract_ability, class: Ddr::Auth::AbstractAbility
  end

end
