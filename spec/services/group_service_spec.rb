require 'spec_helper'

describe DulHydra::Services::GroupService do
  before { @role_service = described_class.new }
  describe "#groups" do
    describe "without user param" do
      before { RoleMapper.stub(:role_names).and_return(["foo", "bar"]) }
      it "should provide a list of groups" do
        @role_service.groups.should eq(["foo", "bar"])
      end
      describe "using #append_groups hook" do
        before { @role_service.stub(:append_groups).and_return(["spam:eggs", "fish:water"]) }
        it "should add the roles to the list" do
          @role_service.groups.should eq(["foo", "bar", "spam:eggs", "fish:water"])
        end
      end
    end
    describe "with user param" do
      before do
        @user = FactoryGirl.build(:user)
        RoleMapper.stub(:roles).with(@user).and_return(["foo", "bar"])
      end      
      it "should provide a list of roles for a user" do
        @role_service.groups(@user).should eq(["foo", "bar"])
      end
      describe "user #append_roles(user) hook" do
        before { @role_service.stub(:append_groups).with(@user).and_return(["spam:eggs", "fish:water"]) }
        it "should add the roles to the list" do
          @role_service.groups(@user).should eq(["foo", "bar", "spam:eggs", "fish:water"])
        end
      end
    end
  end
end
