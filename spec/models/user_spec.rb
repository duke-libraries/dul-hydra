require 'spec_helper'

describe User do
  describe "#member_of?" do
    let(:user) { FactoryGirl.build(:user) }
    it "should return true if the user is a member of the group" do
      user.stub(:groups).and_return(["foo", "bar"])
      user.should be_member_of("foo")
    end
    it "should return false if the user is not a member of the group" do
      user.stub(:groups).and_return(["foo", "bar"])
      user.should_not be_member_of("baz")
    end
  end
end
