FactoryGirl.define do

  factory :attachment do
    dc_title [ "Test Attachment" ]
    sequence(:dc_identifier) { |n| [ "att%05d" % n ] }
    after(:build) do |a|
      a.upload File.new(File.join(Rails.root, 'spec', 'fixtures', 'sample.docx'))
    end

    trait :attached do
      association :attached_to, :factory => :test_model_omnibus
    end
  end

end
