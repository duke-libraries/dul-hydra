FactoryGirl.define do

  factory :attachment do
    title "Test Attachment"
    sequence(:identifier) { |n| "att%05d" % n }
  
    trait :attached_to do
      association :attached_to, factory: test_model
    end
  
    factory :attachment_with_content do
      after(:build) do |a|
        a.content.content = File.new(File.join(Rails.root, 'spec', 'fixtures', 'sample.docx'), "rb")
      end
    end

  end
  
end
