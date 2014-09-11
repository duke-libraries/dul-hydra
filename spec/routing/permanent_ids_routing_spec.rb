require 'spec_helper'

describe "permanent id router", type: :routing, permanent_ids: true do
  it "should have an id route" do
    expect(get: '/id/xyz').to route_to(controller: "permanent_ids", action: "show", permanent_id: "xyz")
  end
end
