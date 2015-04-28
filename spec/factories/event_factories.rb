FactoryGirl.define do

  factory :event do
    sequence(:pid) { |n| "test:#{n}"}
  end

end
