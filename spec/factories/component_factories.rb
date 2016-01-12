FactoryGirl.define do

  factory :component do
    dc_title [ "Test Component" ]
    sequence(:dc_identifier) { |n| [ "cmp%05d" % n ] }
    after(:build) do |c|
      c.upload File.new(File.join(Rails.root, "spec", "fixtures", "imageA.tif"))
    end

    trait :has_parent do
      item
    end

  end
end
