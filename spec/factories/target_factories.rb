FactoryGirl.define do

  factory :target do
    title "Test Target"
    sequence(:identifier) { |n| "tgt%05d" % n }

  end
end
