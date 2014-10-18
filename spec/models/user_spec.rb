require 'spec_helper'

describe User, :type => :model do

  subject { FactoryGirl.build(:user) }

  describe "#member_of?" do
    it "should return true if the user is a member of the group" do
      allow(subject).to receive(:groups).and_return(["foo", "bar"])
      expect(subject).to be_member_of("foo")
    end
    it "should return false if the user is not a member of the group" do
      allow(subject).to receive(:groups).and_return(["foo", "bar"])
      expect(subject).not_to be_member_of("baz")
    end
  end

  describe "#authorized_to_act_as_superuser?" do
    it "should return false if the superuser group is not defined (nil)" do
      DulHydra.superuser_group = nil
      expect(subject).not_to be_authorized_to_act_as_superuser
    end
    it "should return false if the user is not a member of the superuser group" do
      DulHydra.superuser_group = "superusers"
      allow(subject).to receive(:groups).and_return(["normal"])
      expect(subject).not_to be_authorized_to_act_as_superuser
    end
    it "should return true if the user is a member of the superuser group" do
      DulHydra.superuser_group = "superusers"
      allow(subject).to receive(:groups).and_return(["superusers"])
      expect(subject).to be_authorized_to_act_as_superuser
    end
  end

  describe "#principal_name" do
    it "should return the principal name for the user" do
      expect(subject.principal_name).to eq subject.user_key
    end
  end

  describe "#principals" do
    it "should be a list of the user's groups + the user's principal_name" do
      allow(subject).to receive(:groups) { ["foo", "bar"] }
      expect(subject.principals).to match_array ["foo", "bar", subject.principal_name]
    end
  end

  describe "#has_role?" do
    let(:obj) { double }
    it "should send :principal_has_role? to the object with the user's principals" do
      expect(obj).to receive(:principal_has_role?).with(subject.principals, :administrator)
      subject.has_role?(obj, :administrator)
    end
  end

end
