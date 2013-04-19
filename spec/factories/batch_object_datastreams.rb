# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :batch_object_datastream do
    operation "MyString"
    name "MyString"
    payload "MyText"
    payload_type "MyString"
  end
end
