require 'spec_helper'

describe AdminPolicy do
  before do
    AdminPolicy.create_default_apo!
  end
  after do
    AdminPolicy.default_apo.delete
  end
  it "should have a default admin policy object" do
    AdminPolicy.default_apo.should be_kind_of(AdminPolicy)
  end
end
