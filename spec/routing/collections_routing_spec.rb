require 'spec_helper'

describe "collections router" do
  # see also repository_routing_spec
  it "should have a collection_info route" do
    expect(get: "/collections/duke:1/collection_info").to route_to(controller: "collections", action: "collection_info", id: "duke:1")
  end
end
