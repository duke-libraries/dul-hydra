require 'spec_helper'

describe AdminPolicy do
  it "should have a default admin policy object" do
    AdminPolicy.default_apo.should be_kind_of(AdminPolicy)
  end
  # describe "default" do
  #   before do
  #     @apo = AdminPolicy.create
  #   end
  #   after do
  #     @apo.delete
  #   end
  #   it "should have default permissions controlling access to the APO" do
  #     @apo.permissions.should eq(AdminPolicy::DEFAULT_PERMISSIONS)
  #   end
  # end
end
