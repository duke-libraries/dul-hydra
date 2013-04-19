# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :batch_run do
    status "MyString"
    start "2013-04-19 13:25:14"
    stop "2013-04-19 13:25:14"
    outcome "MyString"
    outcome_details "MyText"
  end
end
