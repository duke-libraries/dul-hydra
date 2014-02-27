require 'spec_helper'

describe "attachments routes", attachments: true do
  it "should have a new route" do
    @route = {controller: 'attachments', action: 'new', id: 'duke:1'}
    expect(:get => '/objects/duke:1/attachments/new').to route_to(@route)
    expect(:get => new_attachment_path('duke:1')).to route_to(@route)
  end
  it "should have a create route" do
    @route = {controller: 'attachments', action: 'create', id: 'duke:1'}
    expect(:post => '/objects/duke:1/attachments').to route_to(@route)
    expect(:post => attachments_path('duke:1')).to route_to(@route)
  end
end
