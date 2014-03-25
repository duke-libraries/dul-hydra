require 'spec_helper'
require 'support/shared_examples_for_repository_views'

describe "AdminPolicies views", admin_policies: true do

  describe "rights editing" do
    it_behaves_like "a repository object rights editing view" do
      let(:object) { FactoryGirl.create(:admin_policy) }
    end
  end

  describe "new.html.erb" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      DulHydra.stub(:creatable_models).and_return(["AdminPolicy"])
      DulHydra.stub(:ability_group_map).and_return({"AdminPolicy" => {create: "admin_policy_creators"}}.with_indifferent_access)
      User.any_instance.stub(:groups).and_return(["admin_policy_creators"])    
      login_as user
    end
    after do 
      ActiveFedora::Base.destroy_all
      User.destroy_all
      EventLog.destroy_all
      Warden.test_reset!
    end
    it "should create an AdminPolicy" do
      visit new_admin_policy_path
      fill_in 'Title', with: 'New Admin Policy'
      fill_in 'Description', with: 'Taking over the world!'
      click_button 'Create Admin policy'
      expect(page).to have_text('New Admin Policy')
    end
  end
end
