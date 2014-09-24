require 'spec_helper'

describe User, :type => :model do

  describe "#member_of?" do
    let(:user) { FactoryGirl.build(:user) }
    it "should return true if the user is a member of the group" do
      allow(user).to receive(:groups).and_return(["foo", "bar"])
      expect(user).to be_member_of("foo")
    end
    it "should return false if the user is not a member of the group" do
      allow(user).to receive(:groups).and_return(["foo", "bar"])
      expect(user).not_to be_member_of("baz")
    end
  end

  describe "#superuser?" do
    let(:user) { FactoryGirl.build(:user) }
    it "should return false if the superuser group is not defined (nil)" do
      DulHydra.superuser_group = nil
      expect(user).not_to be_superuser
    end
    it "should return false if the user is not a member of the superuser group" do
      DulHydra.superuser_group = "superusers"
      allow(user).to receive(:groups).and_return(["normal"])
      expect(user).not_to be_superuser
    end
    it "should return true if the user is a member of the superuser group" do
      DulHydra.superuser_group = "superusers"
      allow(user).to receive(:groups).and_return(["superusers"])
      expect(user).to be_superuser
    end
  end

  describe "#has_role?" do
    let(:user) { FactoryGirl.build(:user) }
    let(:role) { Role.new(name: "Admin") }
    before { allow(user).to receive(:effective_roles) { [role] } }
    it "should accept a string parameter" do
      expect(user.has_role?("Admin")).to be_truthy
      expect(user.has_role?("Super")).to be_falsey
    end
    it "should accept a Role parameter" do
      expect(user.has_role?(role)).to be_truthy
      expect(user.has_role?(Role.new(name: "Super"))).to be_falsey      
    end
  end

  describe "#role_abilities" do
    let(:user) { FactoryGirl.build(:user) }
    let(:role1) { Role.new(name: "Role with ability", ability: "create", model: "Collection") }
    let(:role2) { Role.new(name: "Role without ability") }
    it "should return a list of [ability, model] tuples" do
      allow(user).to receive(:effective_roles) { [role1, role2] }
      expect(user.role_abilities).to match_array([[:create, Collection]])
    end
  end

  describe "#effective_roles" do
    subject { user.effective_roles }
    let(:user) { FactoryGirl.create(:user) }
    before { @role = Role.create(name: "Test Role") }
    context "role not granted to user" do
      it "should not include the role" do
        expect(subject).not_to include(@role)
      end
    end
    context "role granted to the user" do
      before do
        @role.user_ids = [user.id]
        @role.save!
      end
      it "should include the role" do
        expect(subject).to include(@role)
      end
    end
    context "role granted to 'public' group" do
      before { @role.update(groups: 'registered') }
      it "should include the role" do
        expect(subject).to include(@role)
      end
    end
    context "role granted to 'registered' group" do
      before { @role.update(groups: 'registered') }
      it "should include the role" do
        expect(subject).to include(@role)
      end      
    end
    context "role granted to user's group" do
      before do
        @role.update(groups: ["Admins"])
        allow(user).to receive(:groups) { ["Admins"] }
      end
      it "should include the role" do
        expect(subject).to include(@role)
      end
    end
  end
end
