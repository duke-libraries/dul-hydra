FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "person#{n}@example.com" }
    email { |u| u.username }
    password "secret"
  end
end
