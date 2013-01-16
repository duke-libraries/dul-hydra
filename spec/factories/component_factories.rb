FactoryGirl.define do

  factory :component do
    title "Test Component"
    sequence(:identifier) { |n| "test%05d" % n }

    factory :component_with_content do
      after(:build) { |c| c.content.content_file = File.new("#{Rails.root}/spec/fixtures/library-devil.tiff", "rb") }
    end

  end
end
