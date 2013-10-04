require 'spec_helper'
require 'helpers/user_helper'

describe "objects/show.html.erb" do
  let(:obejct) { FactoryGirl.create(:test_model) }
  let(:user) { FactoryGirl.create(:user) }
  after(:each) do
    logout user
    object.delete
  end
  after(:all) { user.delete }
  context "object is describable" do
    it "should display the descriptive metadata"
  end
  context "object has preservation events" do
    it "should show the object's last fixity check"
  end
  context "object has content" do
    it "should render the object's content"
  end
  context "object has children" do
    it "should render the object's children"
  end
end
