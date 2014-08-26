require 'spec_helper'
require 'support/shared_examples_for_repository_routers'

describe "items router", type: :routing, items: true do
  it_behaves_like "a repository object router" do
    let(:controller) { "items" }
  end
  it "should have a components route" do
    expect(get: "/items/duke:1/components").to route_to(controller: "items", action: "components", id: "duke:1")
  end
end
