require 'spec_helper'

describe "download routing", type: :routing, downloads: true do
  it "should have file routes" do
    expect(:get => "/download/duke-1/content").to route_to(controller: "downloads", action: "show", id: "duke-1", file: "content")
  end
  it "should have a download route" do
    expect(get: "/download/duke-1").to route_to(controller: "downloads", action: "show", id: "duke-1")
  end
end
