FactoryGirl.define do

  factory :component do
    title "Test Component"
    sequence(:identifier) { |n| "cmp%05d" % n }

    trait :part_of_item do
      container
    end

    trait :has_admin_policy do
      admin_policy
    end

    trait :public_read do
      permissions [{:access => 'read', :type => 'group', :name => 'public'}]
    end

    factory :component_with_content do
      after(:build) { |c| c.content.content_file = File.new("#{Rails.root}/spec/fixtures/library-devil.tiff", "rb") }

      factory :component_with_content_has_apo, traits: [:has_admin_policy]
      factory :component_part_of_item_with_content, traits: [:part_of_item]
      factory :component_part_of_item_with_content_has_apo, traits: [:part_of_item, :has_admin_policy]
    end
    
    factory :component_has_apo,              traits: [:has_admin_policy]
    factory :component_public_read,          traits: [:public_read]
    factory :component_part_of_item,         traits: [:part_of_item]
    factory :component_part_of_item_has_apo, traits: [:part_of_item, :has_admin_policy]

  end
end
