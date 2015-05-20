FactoryGirl.define do

  factory :user do
    sequence(:username) { |n| "person#{n}@example.com" }
    email { |u| u.username }
    password "secret"

    trait :duke do
      sequence(:username) { |n| "person#{n}@duke.edu" }
    end
  end

end
