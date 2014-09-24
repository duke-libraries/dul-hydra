FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "person#{n}" }
    email { |u| "#{u.username}@example.com" }
    password "secret"
  end
end
