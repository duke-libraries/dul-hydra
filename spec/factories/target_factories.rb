FactoryGirl.define do

  factory :target do
    title [ "Test Target" ]
    sequence(:identifier) { |n| [ "tgt%05d" % n ] }
    after(:build) do |c|
      c.upload File.new(File.join(Rails.root, 'spec', 'fixtures', 'target.png'))
    end
  end

end
