require 'spec_helper'
require 'support/shared_examples_for_repository_routers'

describe "AdminPolicy router", admin_policies: true do
  it_behaves_like "a repository object router" do
    let(:controller) { "admin_policies" }
  end
  it "should have default_permissions routes" do
    expect(get: "/admin_policies/duke:1/default_permissions").to route_to(controller: "admin_policies", action: "default_permissions", id: "duke:1")
    expect(patch: "/admin_policies/duke:1/default_permissions").to route_to(controller: "admin_policies", action: "default_permissions", id: "duke:1")
  end
end
