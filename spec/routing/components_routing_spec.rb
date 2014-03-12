require 'spec_helper'

describe "components routes", components: true do
  it "should have a new route" do
    @route = {controller: 'components', action: 'new', id: 'duke:1'}
    expect(:get => '/objects/duke:1/components/new').to route_to(@route)
    expect(:get => new_component_path('duke:1')).to route_to(@route)
  end
  it "should have a create route" do
    @route = {controller: 'components', action: 'create', id: 'duke:1'}
    expect(:post => '/objects/duke:1/components').to route_to(@route)
    expect(:post => components_path('duke:1')).to route_to(@route)
  end
end
