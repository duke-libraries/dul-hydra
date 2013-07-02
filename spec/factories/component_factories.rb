FactoryGirl.define do

  factory :component do
    title "Test Component"
    sequence(:identifier) { |n| "cmp%05d" % n }

    trait :part_of_item do
      container
    end

    trait :has_admin_policy do
      admin_policy { create(:public_read_policy) }
    end

    trait :public_read do
      permissions [{:access => 'read', :type => 'group', :name => 'public'}]
    end
    
    trait :has_target do
      target
    end

    factory :component_with_content do
      after(:build) do |c|
        c.content.content = File.new("#{Rails.root}/spec/fixtures/library-devil.tiff", "rb")
        c.save
        c.generate_content_thumbnail!
      end

      factory :component_with_content_public_read,          :traits => [:public_read]
      factory :component_with_content_has_apo,              :traits => [:has_admin_policy]
      factory :component_part_of_item_with_content,         :traits => [:part_of_item]
      factory :component_part_of_item_with_content_has_apo, :traits => [:part_of_item, :has_admin_policy]
    end
    
    factory :component_has_apo,              :traits => [:has_admin_policy] do
      factory :component_has_apo_with_content_image1 do      
        after(:build) do |c|
          c.content.content = File.new(File.join(Rails.root, 'spec', 'fixtures', 'image1.tiff'))
          c.save
          c.generate_content_thumbnail!
        end
      end      
      factory :component_has_apo_with_content_image2 do      
        after(:build) do |c|
          c.content.content = File.new(File.join(Rails.root, 'spec', 'fixtures', 'image2.tiff'))
          c.save
          c.generate_content_thumbnail!
        end
      end      
      factory :component_has_apo_with_content_image3 do      
        after(:build) do |c|
          c.content.content = File.new(File.join(Rails.root, 'spec', 'fixtures', 'image3.tiff'))
          c.save
          c.generate_content_thumbnail!
        end
      end      
      factory :component_has_apo_with_content_image4 do      
        after(:build) do |c|
          c.content.content = File.new(File.join(Rails.root, 'spec', 'fixtures', 'image4.tiff'))
          c.save
          c.generate_content_thumbnail!
        end
      end      
    end
    
    factory :component_public_read,          :traits => [:public_read]
    factory :component_part_of_item,         :traits => [:part_of_item]
    factory :component_part_of_item_has_apo, :traits => [:part_of_item, :has_admin_policy]
    factory :component_part_of_item_public_read, :traits => [:part_of_item, :public_read]
    factory :component_has_target,           :traits => [:has_target]

  end
end
