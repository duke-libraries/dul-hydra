FactoryGirl.define do

  factory :admin_policy do

    # set permissions on the APO itself
    after(:build) { |apo| apo.permissions = AdminPolicy::APO_PERMISSIONS }

    factory :public_discover_policy do
      after(:build) { |apo| apo.default_permissions = [DulHydra::Permissions::PUBLIC_DISCOVER_ACCESS] }
    end

    factory :registered_discover_policy do
      after(:build) { |apo| apo.default_permissions = [DulHydra::Permissions::REGISTERED_DISCOVER_ACCESS] }
    end

    factory :public_read_policy do
      after(:build) { |apo| apo.default_permissions = [DulHydra::Permissions::PUBLIC_READ_ACCESS] }
    end

    factory :registered_read_policy do
      after(:build) { |apo| apo.default_permissions = [DulHydra::Permissions::REGISTERED_READ_ACCESS] }
    end

    factory :group_read_policy do
      after(:build) { |apo| apo.default_permissions = [DulHydra::Permissions::READER_GROUP_ACCESS] }
    end

    factory :group_edit_policy do
      after(:build) { |apo| apo.default_permissions = [DulHydra::Permissions::EDITOR_GROUP_ACCESS] }
    end

  end

end
