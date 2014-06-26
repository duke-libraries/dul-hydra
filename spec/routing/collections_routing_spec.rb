require 'spec_helper'
require 'support/shared_examples_for_repository_routers'

describe "collections router", collections: true do
  it_behaves_like "a repository object router" do
    let(:controller) { "collections" }
  end
  it "should have a collection_info route" do
    expect(get: "/collections/duke:1/collection_info").to route_to(controller: "collections", action: "collection_info", id: "duke:1")
  end
end
