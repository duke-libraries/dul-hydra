FactoryGirl.define do
  factory :metadata_file do
    metadata { File.new(Rails.root.join('spec', 'fixtures', 'batch_update', 'qdc_csv.csv')) }
    profile { File.join(Rails.root, 'spec', 'fixtures', 'batch_update', 'QDC_CSV.yml') }
  end
end