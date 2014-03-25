FactoryGirl.define do

  factory :admin_policy do
    title "Admin Policy"

    trait :public_discover do
      title "Public discover policy"
      default_permissions [DulHydra::Permissions::PUBLIC_DISCOVER_ACCESS]
    end

    trait :registered_discover do
      title "Registered discover policy"
      default_permissions [DulHydra::Permissions::REGISTERED_DISCOVER_ACCESS]
    end

    trait :public_read do
      title "Public read policy"
      default_permissions [DulHydra::Permissions::PUBLIC_READ_ACCESS]
    end

    trait :registered_read do
      title "Registered read policy"
      default_permissions [DulHydra::Permissions::REGISTERED_READ_ACCESS]
    end

    trait :group_read do
      title "Group read policy"
      default_permissions [DulHydra::Permissions::READER_GROUP_ACCESS]
    end

    trait :group_edit do
      title "Group edit policy"
      default_permissions [DulHydra::Permissions::EDITOR_GROUP_ACCESS]
    end

    factory :public_discover_policy,     :traits => [:public_discover]
    factory :registered_discover_policy, :traits => [:registered_discover]
    factory :public_read_policy,         :traits => [:public_read]
    factory :registered_read_policy,     :traits => [:registered_read]
    factory :group_read_policy,          :traits => [:group_read]
    factory :group_edit_policy,          :traits => [:group_edit]

  end

end
