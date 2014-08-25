require 'spec_helper'
require 'support/shared_examples_for_repository_routers'

describe "targets router", type: :routing, targets: true do
  it "should not have a new route" do
    expect(get: "/targets/new").not_to be_routable
  end
  it "should not have a create route" do
    expect(post: "/targets").not_to be_routable
  end  
  it_behaves_like "a repository object router" do
    let(:controller) { "targets" }
  end
  it_behaves_like "a content-bearing object router" do
    let(:controller) { "targets" }
  end
end
