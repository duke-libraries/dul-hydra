# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ingest_folder do
    base_path "/base/path/"
    sub_path "/subpath/"
    user { FactoryGirl.create(:user) }
    admin_policy_pid "apo:123"
    collection_pid "test:456"
    add_parents true
    parent_id_length 1
  end
end
