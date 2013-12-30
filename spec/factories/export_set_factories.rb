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

    factory :content_export_set, traits: [:content]
    factory :descriptive_metadata_export_set, traits: [:descriptive_metadata]
  end

end
