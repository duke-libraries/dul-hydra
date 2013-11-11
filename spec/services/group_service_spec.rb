require 'spec_helper'

describe DulHydra::Services::GroupService do
  before { @group_service = described_class.new }
  describe "#groups" do
    describe "without user param" do
      before { RoleMapper.stub(:role_names).and_return(["foo", "bar"]) }
      it "should provide a list of groups" do
        @group_service.groups.sort.should eq(["foo", "bar", "public", "registered"].sort)
      end
      describe "using #append_groups hook" do
        before { @group_service.stub(:append_groups).and_return(["spam:eggs", "fish:water"]) }
        it "should add the roles to the list" do
          @group_service.groups.sort.should eq(["foo", "bar", "spam:eggs", "fish:water", "public", "registered"].sort)
        end
      end
    end
    describe "with user param" do
      before do
        @user = FactoryGirl.build(:user)
        RoleMapper.stub(:roles).with(@user).and_return(["foo", "bar"])
      end      
      it "should provide a list of groups for a user" do
        @group_service.groups(@user).sort.should eq(["foo", "bar", "public"].sort)
      end
      describe "user #append_groups(user) hook" do
        before { @group_service.stub(:append_groups).with(@user).and_return(["spam:eggs", "fish:water"]) }
        it "should add the groups to the list" do
          @group_service.groups(@user).sort.should eq(["foo", "bar", "spam:eggs", "fish:water", "public"].sort)
        end
      end
    end
  end
end
