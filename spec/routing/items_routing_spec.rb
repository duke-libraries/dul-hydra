require 'spec_helper'
require 'support/shared_examples_for_repository_routers'

describe "items router", type: :routing, items: true do
  let(:controller) { "items" }

  let(:id) { "bc/a8/30/13/bca83013-2c43-40e4-8779-add4b29fac2f" }
  let(:escaped_id) { "bc%2Fa8%2F30%2F13%2Fbca83013-2c43-40e4-8779-add4b29fac2f" }

  include_examples "a repository object router"
  include_examples "a creatable object router"

  it "should have a components route" do
    expect(get: "/items/#{escaped_id}/components")
      .to route_to(controller: "items", action: "components", id: id)
  end
end
