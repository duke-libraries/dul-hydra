FactoryGirl.define do

  factory :component do
    title "Test Component"
    sequence(:identifier) { |n| "cmp%05d" % n }
    
    trait :has_target do
      target
    end
    
    trait :has_parent do
      item
    end

    factory :component_with_content do
      after(:build) do |c|
        c.upload! File.new("#{Rails.root}/spec/fixtures/library-devil.tiff", "rb")
      end
    end
    
    factory :component_with_content_image1 do      
      after(:build) do |c|
        c.upload! File.new(File.join(Rails.root, 'spec', 'fixtures', 'image1.tiff'))
      end
    end      
    factory :component_with_content_image2 do      
      after(:build) do |c|
        c.upload! File.new(File.join(Rails.root, 'spec', 'fixtures', 'image2.tiff'))
      end
    end      
    factory :component_with_content_image3 do      
      after(:build) do |c|
        c.upload! File.new(File.join(Rails.root, 'spec', 'fixtures', 'image3.tiff'))
      end
    end      
    factory :component_with_content_image4 do      
      after(:build) do |c|
        c.upload! File.new(File.join(Rails.root, 'spec', 'fixtures', 'image4.tiff'))
      end
    end      
    
    factory :component_has_target, :traits => [:has_target]

    factory :component_has_parent, :traits => [:has_parent]
    
  end
end
