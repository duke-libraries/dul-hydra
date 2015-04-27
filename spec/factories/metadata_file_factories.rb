FactoryGirl.define do

  factory :metadata_file do
    user { FactoryGirl.create(:user) }

    factory :metadata_file_descmd_csv do
      metadata { File.new(Rails.root.join('spec', 'fixtures', 'batch_update', 'descmd_csv.csv')) }
      profile { File.join(Rails.root, 'spec', 'fixtures', 'batch_update', 'DESCMD_CSV.yml') }
    end

    factory :metadata_file_mapped_tab do
      metadata { File.new(Rails.root.join('spec', 'fixtures', 'batch_update', 'mapped_tab.txt')) }
      profile { File.join(Rails.root, 'spec', 'fixtures', 'batch_update', 'mapped_tab.yml') }
    end

  end

end



