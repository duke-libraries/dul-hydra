require 'spec_helper'
require 'support/shared_examples_for_repository_routers'

describe "targets router", type: :routing, targets: true do
  let(:controller) { "targets" }

  include_examples "a repository object router"
  include_examples "a content-bearing object router"

  it "should not have a new route" do
    pending "Decision on whether to re-add an :id route segment constraint"
    expect(get: "/targets/new").not_to be_routable
  end
  it "should not have a create route" do
    expect(post: "/targets").not_to be_routable
  end
end
