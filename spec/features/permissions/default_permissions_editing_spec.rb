require 'spec_helper'

describe "default permissions editing" do
  let(:user) { FactoryGirl.create(:user) }
  let(:object) { AdminPolicy.create }
  before do
    object.edit_users = [user.user_key]
    object.default_permissions = [{type: "group", access: "read", name: "registered"},
                                  {type: "group", access: "edit", name: "repositoryEditor"}]
    object.default_license_title = "Wide Open"
    object.default_license_description = "Anyone can do anything"
    object.save
    login_as user
  end
  after do
    object.delete
    user.delete
    Warden.test_reset!
  end
  it "should be idempotent" do
    original_default_permissions = object.default_permissions
    visit default_permissions_edit_path(object)
    click_button "Save"
    object.reload
    object.default_permissions.should == original_default_permissions
    
    object.default_edit_groups.should == ["repositoryEditor"]
    object.default_read_groups.should == ["registered"]
    object.default_license_title.should == "Wide Open"
    object.default_license_description.should == "Anyone can do anything"
  end
  it "should be able to remove a permission" do
    visit default_permissions_edit_path(object)
    page.unselect "Duke Community", from: "permissions_read"
    click_button "Save"
    object.reload
    object.default_read_groups.should be_empty
  end
  it "should be able to add a permission" do
    visit default_permissions_edit_path(object)
    page.select "repositoryAdmin", from: "permissions_edit"
    click_button "Save"
    object.reload
    object.default_edit_groups.sort.should == ["repositoryEditor", "repositoryAdmin"].sort
  end
  it "should be able to modify the license" do
    visit default_permissions_edit_path(object)
    fill_in "license[title]", with: "No Access"
    fill_in "license[description]", with: "No one can get to it"
    click_button "Save"
    object.reload
    object.default_license_title.should == "No Access"
    object.default_license_description.should == "No one can get to it"
  end
end
