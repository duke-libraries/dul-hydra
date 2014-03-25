require 'spec_helper'

describe "AdminPolicy router", admin_policies: true do
  # see also repository_router_spec
  it "should not have events routes" do
    expect(get: "/admin_policies/duke:1/preservation_events").not_to be_routable
  end
  it "should have default_permissions routes" do
    expect(get: "/admin_policies/duke:1/default_permissions").to route_to(controller: "admin_policies", action: "default_permissions", id: "duke:1")
    expect(patch: "/admin_policies/duke:1/default_permissions").to route_to(controller: "admin_policies", action: "default_permissions", id: "duke:1")
  end
end
