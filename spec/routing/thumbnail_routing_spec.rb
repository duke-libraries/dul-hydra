require 'spec_helper'

describe "thumbnail routing", type: :routing, thumbnails: true do
  it "should have a thumbnail route" do
    expect(:get => "/thumbnail/duke:1").to route_to(controller: "thumbnail", action: "show", id: "duke:1")
  end
end
