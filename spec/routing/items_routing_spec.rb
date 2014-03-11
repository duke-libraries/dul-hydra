require 'spec_helper'

describe "items routes", items: true do
  it "should have a new route" do
    @route = {controller: 'items', action: 'new', id: 'duke:1'}
    expect(:get => '/objects/duke:1/items/new').to route_to(@route)
    expect(:get => new_item_path('duke:1')).to route_to(@route)
  end
  it "should have a create route" do
    @route = {controller: 'items', action: 'create', id: 'duke:1'}
    expect(:post => '/objects/duke:1/items').to route_to(@route)
    expect(:post => items_path('duke:1')).to route_to(@route)
  end
end
