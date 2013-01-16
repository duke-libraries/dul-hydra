FactoryGirl.define do

  factory :item do
    title "Test Item"
    sequence(:identifier) { |n| "item%05d" % n }
  end

end
