require 'spec_helper'

describe "policy view", :type => :feature do
  let(:user) { FactoryGirl.create(:user) }
  let(:object) { FactoryGirl.create(:collection) }
  before do
    allow(Ddr::Auth::Groups).to receive(:all) { ["public", "registered", "repositoryEditor", "repositoryAdmin" ] }
    object.edit_users = [user.user_key]
    object.default_permissions = [{type: "group", access: "read", name: "registered"},
                                  {type: "group", access: "edit", name: "repositoryEditor"}]
    object.default_license_title = "Wide Open"
    object.default_license_description = "Anyone can do anything"
    object.save
    login_as user
  end
  it "should be idempotent" do
    original_default_permissions = object.default_permissions
    visit url_for(controller: object.controller_name, action: "default_permissions", id: object)
    click_button "Save"
    object.reload
    expect(object.default_permissions).to eq(original_default_permissions)

    expect(object.default_edit_groups).to eq(["repositoryEditor"])
    expect(object.default_read_groups).to eq(["registered"])
    expect(object.default_license_title).to eq("Wide Open")
    expect(object.default_license_description).to eq("Anyone can do anything")
  end
  it "should be able to remove a permission" do
    visit url_for(controller: object.controller_name, action: "default_permissions", id: object)
    page.unselect "Duke Community", from: "permissions_read"
    click_button "Save"
    object.reload
    expect(object.default_read_groups).to be_empty
  end
  it "should be able to add a permission" do
    visit url_for(controller: object.controller_name, action: "default_permissions", id: object)
    page.select "repositoryAdmin", from: "permissions_edit"
    click_button "Save"
    object.reload
    expect(object.default_edit_groups.sort).to eq(["repositoryEditor", "repositoryAdmin"].sort)
  end
  it "should be able to modify the license" do
    visit url_for(controller: object.controller_name, action: "default_permissions", id: object)
    fill_in "license[title]", with: "No Access"
    fill_in "license[description]", with: "No one can get to it"
    click_button "Save"
    object.reload
    expect(object.default_license_title).to eq("No Access")
    expect(object.default_license_description).to eq("No one can get to it")
  end
end
