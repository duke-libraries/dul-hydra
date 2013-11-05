# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ingest_folder do
    dirpath "MyString"
    username "MyString"
    admin_policy_pid "MyString"
    collection_pid "MyString"
    model "MyString"
    add_parents false
    parent_id_length 1
  end
end
