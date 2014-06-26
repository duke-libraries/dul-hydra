FactoryGirl.define do

  factory :admin_policy do
    # AdminPolicy title must be present and unique
    sequence(:title) { |n| "Admin Policy #{n}" }

    factory :public_read_policy do
      default_permissions [{:name => "public", :type => "group", :access => "read"}]
    end
  end

end
