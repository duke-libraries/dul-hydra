require 'spec_helper'

describe "Collection routes" do
  it "should have a new route" do
    expect(get: '/collections/new').to route_to(controller: 'collections', action: 'new')
    expect(get: new_collection_path).to route_to(controller: 'collections', action: 'new')
  end
  it "should have a create route" do
    expect(post: '/collections').to route_to(controller: 'collections', action: 'create')
    expect(post: collections_path).to route_to(controller: 'collections', action: 'create')
  end
end
