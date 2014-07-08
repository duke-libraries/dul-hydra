require 'spec_helper'
require 'support/shared_examples_for_repository_views'

describe "Collections views", collections: true do

  describe "show" do
    let(:object) { FactoryGirl.create(:collection) }
    it_behaves_like "a repository object show view"
  end

  describe "edit/update" do
    let(:object) { FactoryGirl.create(:collection) }
    it_behaves_like "a repository object descriptive metadata editing view"
  end

  describe "permissions" do
    let(:object) { FactoryGirl.create(:collection) }
    it_behaves_like "a governable repository object rights editing view"
  end

  describe "new/create" do
    let(:user) { FactoryGirl.create(:user) }
    let(:admin_policy) { FactoryGirl.create(:admin_policy) }
    let(:collection_creator) { Role.new("Collection Creator", ability: :create, model: "Collection") }
    before do
      allow(User.any_instance).to receive(:roles) { [collection_creator] }
      admin_policy.default_permissions = [DulHydra::Permissions::PUBLIC_DISCOVER_ACCESS]
      admin_policy.read_users = [user.user_key]
      admin_policy.save!
      login_as user
    end
    it "should create a collection" do
      pending "Figuring out how to write the test"
      visit new_collection_path
      fill_in 'Title', with: 'New Collection'
      select admin_policy.title, from: 'admin_policy_id'
      click_button 'Create Collection'
      expect(page).to have_text("New Collection")
    end
  end
end
