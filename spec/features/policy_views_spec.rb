require 'spec_helper'

describe "policy view" do
  let(:user) { FactoryGirl.create(:user) }
  let(:object) { FactoryGirl.create(:admin_policy) }
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
    User.destroy_all
    ActiveFedora::Base.destroy_all
    EventLog.destroy_all
    Warden.test_reset!
  end
  it "should be idempotent" do
    original_default_permissions = object.default_permissions
    visit url_for(controller: object.controller_name, action: "default_permissions", id: object)
    click_button "Save"
    object.reload
    object.default_permissions.should == original_default_permissions
    
    object.default_edit_groups.should == ["repositoryEditor"]
    object.default_read_groups.should == ["registered"]
    object.default_license_title.should == "Wide Open"
    object.default_license_description.should == "Anyone can do anything"
  end
  it "should be able to remove a permission" do
    visit url_for(controller: object.controller_name, action: "default_permissions", id: object)
    page.unselect "Duke Community", from: "permissions_read"
    click_button "Save"
    object.reload
    object.default_read_groups.should be_empty
  end
  it "should be able to add a permission" do
    visit url_for(controller: object.controller_name, action: "default_permissions", id: object)
    page.select "repositoryAdmin", from: "permissions_edit"
    click_button "Save"
    object.reload
    object.default_edit_groups.sort.should == ["repositoryEditor", "repositoryAdmin"].sort
  end
  it "should be able to modify the license" do
    visit url_for(controller: object.controller_name, action: "default_permissions", id: object)
    fill_in "license[title]", with: "No Access"
    fill_in "license[description]", with: "No one can get to it"
    click_button "Save"
    object.reload
    object.default_license_title.should == "No Access"
    object.default_license_description.should == "No one can get to it"
  end
end
