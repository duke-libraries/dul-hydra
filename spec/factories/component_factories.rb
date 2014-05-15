FactoryGirl.define do

  factory :component do
    title "Test Component"
    sequence(:identifier) { |n| "cmp%05d" % n }

    trait :has_admin_policy do
      admin_policy { create(:public_read_policy) }
    end
    
    trait :has_target do
      target
    end

    factory :component_with_content do
      after(:build) do |c|
        c.upload! File.new("#{Rails.root}/spec/fixtures/library-devil.tiff", "rb")
      end

      factory :component_with_content_has_apo, :traits => [:has_admin_policy]
    end
    
    factory :component_has_apo,              :traits => [:has_admin_policy] do
      factory :component_has_apo_with_content_image1 do      
        after(:build) do |c|
          c.upload! File.new(File.join(Rails.root, 'spec', 'fixtures', 'image1.tiff'))
        end
      end      
      factory :component_has_apo_with_content_image2 do      
        after(:build) do |c|
          c.upload! File.new(File.join(Rails.root, 'spec', 'fixtures', 'image2.tiff'))
        end
      end      
      factory :component_has_apo_with_content_image3 do      
        after(:build) do |c|
          c.upload! File.new(File.join(Rails.root, 'spec', 'fixtures', 'image3.tiff'))
        end
      end      
      factory :component_has_apo_with_content_image4 do      
        after(:build) do |c|
          c.upload! File.new(File.join(Rails.root, 'spec', 'fixtures', 'image4.tiff'))
        end
      end      
    end
    
    factory :component_has_target, :traits => [:has_target]

  end
end
