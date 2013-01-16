FactoryGirl.define do

  factory :collection do
    title "Test Collection"
    sequence(:identifier) { |n| "coll%05d" % n }
  end

end
