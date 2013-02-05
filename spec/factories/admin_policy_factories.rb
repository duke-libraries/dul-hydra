FactoryGirl.define do

  factory :admin_policy do
    permissions AdminPolicy::APO_PERMISSIONS
    title "Admin Policy"

    trait :public_discover do
      default_permissions [DulHydra::Permissions::PUBLIC_DISCOVER_ACCESS]
      title "Public discover policy"
    end

    trait :registered_discover do
      default_permissions [DulHydra::Permissions::REGISTERED_DISCOVER_ACCESS]
      title "Registered discover policy"
    end

    trait :public_read do
      default_permissions [DulHydra::Permissions::PUBLIC_READ_ACCESS]
      title "Public read policy"
    end

    trait :registered_read do
      default_permissions [DulHydra::Permissions::REGISTERED_READ_ACCESS]
      title "Registered read policy"
    end

    trait :group_read do
      default_permissions [DulHydra::Permissions::READER_GROUP_ACCESS]
      title "Group read policy"
    end

    trait :group_edit do
      default_permissions [DulHydra::Permissions::EDITOR_GROUP_ACCESS]
      title "Group edit policy"
    end

    factory :public_discover_policy,     traits: [:public_discover]
    factory :registered_discover_policy, traits: [:registered_discover]
    factory :public_read_policy,         traits: [:public_read]
    factory :registered_read_policy,     traits: [:registered_read]
    factory :group_read_policy,          traits: [:group_read]
    factory :group_edit_policy,          traits: [:group_edit]

  end

end
