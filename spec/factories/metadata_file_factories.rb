FactoryGirl.define do

  factory :metadata_file do
    user { FactoryGirl.create(:user) }

    factory :metadata_file_descmd_csv do
      metadata { File.new(Rails.root.join('spec', 'fixtures', 'batch_update', 'metadata_csv.csv')) }
      profile { File.join(Rails.root, 'spec', 'fixtures', 'batch_update', 'METADATA_CSV.yml') }
    end

  end

end



