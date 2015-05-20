FactoryGirl.define do

  factory :auth_context, class: Ddr::Auth::AuthContext do

    association :user, factory: :user, strategy: :build
    env Hash.new

    initialize_with { Ddr::Auth::AuthContextFactory.call(user, env) }

    trait :anonymous do
      user nil
    end

    trait :duke do
      association :user, :duke, factory: :user, strategy: :build
    end
  end
end
