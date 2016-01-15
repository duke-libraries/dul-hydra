FactoryGirl.define do
  factory :ingest_folder do
    model "TestChild"
    base_path "base/path/"
    sub_path "subpath"
    checksum_type Ddr::Datastreams::CHECKSUM_TYPE_SHA1
    collection_pid "test:456"
    add_parents true
    parent_id_length 1
  end
end
