FactoryGirl.define do

  factory :attachment do
    title "Test Attachment"
    sequence(:identifier) { |n| "att%05d" % n }
  
<<<<<<< HEAD
    trait :attached do
      association :attached_to, :factory => :test_model
=======
    trait :attached_to do
      association :attached_to, factory: test_model
>>>>>>> 6fab6581ef93838c795c77b25b33197954195bf4
    end
  
    factory :attachment_with_content do
      after(:build) do |a|
        a.content.content = File.new(File.join(Rails.root, 'spec', 'fixtures', 'sample.docx'), "rb")
      end
    end

<<<<<<< HEAD
    factory :attached_attachment, :traits => [:attached]

    factory :attached_attachment_with_content, :traits => [:attached] do
      after(:build) do |a|
        a.content.content = File.new(File.join(Rails.root, 'spec', 'fixtures', 'sample.docx'), "rb")
      end
    end

=======
>>>>>>> 6fab6581ef93838c795c77b25b33197954195bf4
  end
  
end
