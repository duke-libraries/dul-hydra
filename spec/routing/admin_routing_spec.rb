require 'spec_helper'

RSpec.describe "admin routers", type: :routing do

  it "should have a dashboard route" do
    expect(get: "/admin/dashboard").to route_to(controller: "admin/dashboard", action: "show")
  end

  it "should have a report route" do
    expect(get: "/admin/reports/techmd").to route_to(controller: "admin/reports", action: "show", type: "techmd")
  end

end
