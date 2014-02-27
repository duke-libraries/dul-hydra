require 'spec_helper'

describe "AdminPolicy routes", admin_policies: true do
  it "should have a new route" do
    expect(get: '/admin_policies/new').to route_to(controller: 'admin_policies', action: 'new')
    expect(get: new_admin_policy_path).to route_to(controller: 'admin_policies', action: 'new')
  end
  it "should have a create route" do
    expect(post: '/admin_policies').to route_to(controller: 'admin_policies', action: 'create')
    expect(post: admin_policies_path).to route_to(controller: 'admin_policies', action: 'create')
  end
end
