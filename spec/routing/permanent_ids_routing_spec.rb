require 'spec_helper'

describe "permanent id router", type: :routing, permanent_ids: true do
  it "should have an id route" do
    expect(get: '/id/ark:/99999/fk4').to route_to(controller: "permanent_ids", action: "show", permanent_id: "ark:/99999/fk4")
  end
end
