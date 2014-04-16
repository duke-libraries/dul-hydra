require 'spec_helper'
require 'support/shared_examples_for_repository_views'

describe "Collections views" do

  describe "show" do
    it_behaves_like "a repository object show view" do
      let(:object) { FactoryGirl.create(:collection) }
    end
  end

  describe "rights editing" do
    it_behaves_like "a governable repository object rights editing view" do
      let(:object) { FactoryGirl.create(:collection) }
    end
  end

  describe "new.html.erb" do
    let(:user) { FactoryGirl.create(:user) }
    let(:admin_policy) { FactoryGirl.create(:public_discover_policy) }
    before do
      DulHydra.stub(:creatable_models).and_return(["Collection"])
      DulHydra.stub(:ability_group_map).and_return({"Collection" => {create: "collection_admins"}}.with_indifferent_access)
      User.any_instance.stub(:groups).and_return(["collection_admins"])
      admin_policy.read_users = [user.user_key]
      admin_policy.save!
      login_as user
    end
    after do 
      ActiveFedora::Base.destroy_all
      user.destroy
      Warden.test_reset!
    end
    it "should create a collection" do
      visit new_collection_path
      fill_in 'Title', with: 'New Collection'
      select admin_policy.title, from: 'admin_policy_id'
      click_button 'Create Collection'
      expect(page).to have_text("New Collection")
    end
  end
end
