require 'spec_helper'

describe "permissions editing" do
  let(:user) { FactoryGirl.create(:user) }
  let(:object) { FactoryGirl.create(:test_model) }
  before do
    object.edit_users = [user.user_key]
    object.read_groups = ["registered"]
    object.discover_groups = ["public"]
    object.license_title = "Wide Open"
    object.license_description = "Anyone can do anything"
    object.save
    login_as user
  end
  after do
    object.destroy
    user.delete
    Warden.test_reset!
  end
  it "should be idempotent" do
    original_permissions = object.permissions
    visit permissions_edit_path(object)
    click_button "Save"
    object.reload
    object.permissions.should == original_permissions
    object.edit_users.should == [user.user_key]
    object.read_groups.should == ["registered"]
    object.discover_groups.should == ["public"]
    object.license_title.should == "Wide Open"
    object.license_description.should == "Anyone can do anything"
  end
  it "should be able to remove a permission" do
    visit permissions_edit_path(object)
    page.unselect "Public", from: "permissions_discover"
    click_button "Save"
    object.reload
    object.discover_groups.should be_empty
  end
  it "should be able to add a permission" do
    visit permissions_edit_path(object)
    page.select "Duke Community", from: "permissions_edit"
    click_button "Save"
    object.reload
    object.edit_groups.should == ["registered"]
  end
  it "should be able to modify the license" do
    visit permissions_edit_path(object)
    fill_in "license_title", with: "No Access"
    fill_in "license_description", with: "No one can get to it"
    click_button "Save"
    object.reload
    object.license_title.should == "No Access"
    object.license_description.should == "No one can get to it"
  end
end
