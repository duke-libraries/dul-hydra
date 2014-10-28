require 'spec_helper'

describe "download routing", type: :routing, downloads: true do
  it "should have datastream routes" do
    expect(:get => "/download/duke:1/descMetadata").to route_to(controller: "downloads", action: "show", id: "duke:1", datastream_id: "descMetadata")
  end
  it "should have a download route" do
    expect(get: "/download/duke:1").to route_to(controller: "downloads", action: "show", id: "duke:1")
  end
end
