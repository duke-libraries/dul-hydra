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
      allow(Ability.any_instance).to receive(:role_abilities) { [[:create, AdminPolicy]] }
      login_as user
    end
    it "should create an AdminPolicy" do
      pending "Figuring out how to write the test"
      visit new_admin_policy_path
      fill_in 'Title', with: 'New Admin Policy'
      fill_in 'Description', with: 'Taking over the world!'
      click_button 'Create Admin policy'
      expect(page).to have_text('New Admin Policy')
    end
  end
end
