FactoryGirl.define do

  factory :export_set do
    title 'Test Export Set'
    user

    trait :content do
      export_type ExportSet::Types::CONTENT
    end

    trait :descriptive_metadata do
      export_type ExportSet::Types::DESCRIPTIVE_METADATA
    end
    
    trait :pids do
      pids ["test:123"]
    end
    
    trait :csv_col_sep do
      csv_col_sep 'tab'
    end

    factory :content_export_set, traits: [:content]
    factory :descriptive_metadata_export_set, traits: [:descriptive_metadata]
    
    factory :content_export_set_with_pids, traits: [:content, :pids]
    factory :descriptive_metadata_export_set_with_pids, traits: [:descriptive_metadata, :pids]
    
    factory :descriptive_metadata_export_set_with_pids_with_csv_col_sep, traits: [:descriptive_metadata, :pids, :csv_col_sep]
  end

end
