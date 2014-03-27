require 'spec_helper'

describe "users router" do
  it "should not have registration routes" do
    expect(get: "/users/sign_up").not_to be_routable
    expect(get: "/users/edit").not_to be_routable
    expect(get: "/users/cancel").not_to be_routable
    expect(post: "/users").not_to be_routable
    expect(put: "/users").not_to be_routable
    expect(patch: "/users").not_to be_routable
    expect(delete: "/users").not_to be_routable
  end
end
