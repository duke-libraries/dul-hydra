FactoryGirl.define do

  factory :target do
    dc_title [ "Test Target" ]
    sequence(:dc_identifier) { |n| [ "tgt%05d" % n ] }
    after(:build) do |c|
      c.upload File.new(File.join(Rails.root, 'spec', 'fixtures', 'target.png'))
    end
  end

end
