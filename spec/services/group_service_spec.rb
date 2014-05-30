require 'spec_helper'

describe DulHydra::Services::GroupService do  
  subject { described_class.new }
  
  describe "#groups" do
    describe "at minimum" do
      it "should include the 'public' and 'registered' groups" do
        expect(subject.groups).to include("public", "registered")
      end
    end
    describe "using #append_groups hook" do
      before { allow(subject).to receive(:append_groups).and_return(["spam:eggs", "fish:water"]) }
      it "should add the groups to the list" do
        expect(subject.groups).to include("spam:eggs", "fish:water")
      end
    end
    describe "when RoleMapper config file is present and not empty" do
      before do
        allow(described_class).to receive(:include_role_mapper_groups).and_return(true)
        allow(RoleMapper).to receive(:role_names).and_return(["foo", "bar"])
      end
      it "should include the role mapper groups" do
        expect(subject.groups).to include("foo", "bar")
      end
    end
    describe "when RoleMapper config file is missing or empty" do
      before { allow(described_class).to receive(:include_role_mapper_groups).and_return(false) }
      it "should only include the default minimum groups" do
        expect(subject.groups).to match_array(["public", "registered"])
      end
    end
  end
  
  describe "#user_groups(user)" do
    describe "when user is not persisted" do
      let(:user) { FactoryGirl.build(:user) }
      it "should return only 'public' group" do
        expect(subject.user_groups(user)).to eq(["public"])
      end
    end
    describe "when the user is persisted" do
      let(:user) { FactoryGirl.create(:user) }
      it "should include the 'public' and 'registered' groups" do
        expect(subject.user_groups(user)).to include("public", "registered")
      end
      describe "using #append_user_groups(user) hook" do
        before { allow(subject).to receive(:append_user_groups).with(user).and_return(["spam:eggs", "fish:water"]) }
        it "should add the groups to the list" do
          expect(subject.user_groups(user)).to include("spam:eggs", "fish:water")
        end
      end
      describe "when the RoleMapper config file is present and not empty" do
        before do
          allow(described_class).to receive(:include_role_mapper_groups).and_return(true)
          allow(RoleMapper).to receive(:roles).with(user).and_return(["foo", "bar"])
        end
        it "should add the user's roles to the list" do
          expect(subject.user_groups(user)).to include("foo", "bar")
        end
      end
      describe "when RoleMapper config file is missing or empty" do
        before { allow(described_class).to receive(:include_role_mapper_groups).and_return(false) }
        it "should only include the default minimum groups" do
          expect(subject.groups).to match_array(["public", "registered"])
        end
      end
    end
  end
end

