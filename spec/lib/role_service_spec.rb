require 'spec_helper'

describe DulHydra::RoleService do
  before do
    RoleMapper.stub(:role_names).and_return(["foo", "bar"])
    DulHydra::Grouper::Client.stub(:repository_group_names).and_return(["duke:library:repository:ddr:awesome"])
  end
  it "should provide a list of role names" do
    DulHydra::RoleService.role_names.should eq(["foo", "bar", "duke:library:repository:ddr:awesome"])
  end
end
