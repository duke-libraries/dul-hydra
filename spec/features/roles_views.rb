require 'spec_helper'

describe "roles views", :type => :feature do
  let(:user) { FactoryGirl.create(:user) }
  before do
    login_as user
    login_as user, scope: :superuser
  end
  describe "index" do
    let!(:role) { Role.create(name: "Manager") }
    it "should list the roles" do
      visit roles_path
      expect(page).to have_link("Manager", href: role_path(role))
    end
  end
  describe "new" do
    it "should render a new role form" do
      visit new_role_path
      expect(page).to have_css("form#new_role")
      # fill_in "Name", with: "Manager"
      # select "Collection", from: "Model"
      # select "create", from: "Ability"
      # select user.user_key, from: "Users"
      # fill_in "Groups", with: "Admins\nManagers"
      # click_button "Create Role"
      # role = Role.find_by_name("Manager")
      # expect(role).to be_a(Role)
      # expect(role.model).to eq("Collection")
      # expect(role.ability).to eq("create")
      # expect(role.user_ids).to eq([user.id])
      # expect(role.groups).to eq(["Admins", "Managers"])
    end
  end
  describe "edit" do
    let(:role) { Role.create(name: "Manager") }
    it "should render an edit role form" do
      visit edit_role_path(role)
      expect(page).to have_css("form.edit_role")
    end
  end
  describe "show" do
    let(:role) { Role.create(name: "Manager") }
    it "should render a show template" do
      visit role_path(role)
      expect(page).to have_content("Manager")
    end    
  end
end
