require 'spec_helper'

describe "attachments router", targets: true do
  # see also repository_router_spec  
  it "should not have a new route" do
    expect(get: "/targets/new").not_to be_routable
  end
  it "should not have a create route" do
    expect(post: "/targets").not_to be_routable
  end  
end
