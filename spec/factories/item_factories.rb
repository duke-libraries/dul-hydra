FactoryGirl.define do

  factory :item, :aliases => [:container] do
    title "Test Item"
    sequence(:identifier) { |n| "item%05d" % n }

    trait :member_of_collection do
      collection
    end
    
    factory :item_has_part do
      after(:create) { |i| i.parts << FactoryGirl.create(:component) }
      factory :item_in_collection_has_part, :traits => [:member_of_collection]
    end

    factory :item_in_collection, :traits => [:member_of_collection]
    
    factory :item_with_components_image1_and_image2 do
      after(:create) do |i|
        i.parts << FactoryGirl.create(:component_with_content_image1)
        i.parts << FactoryGirl.create(:component_with_content_image2)
      end
    end
    factory :item_with_components_image3_and_image4 do
      after(:create) do |i|
        i.parts << FactoryGirl.create(:component_with_content_image3)
        i.parts << FactoryGirl.create(:component_with_content_image4)
      end
    end
  end

end
