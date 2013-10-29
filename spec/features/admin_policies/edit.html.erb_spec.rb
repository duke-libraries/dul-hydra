require 'spec_helper'
require 'helpers/user_helper'

describe 'admin_policies/edit.html.erb' do
  let(:apo) { FactoryGirl.create(:admin_policy) }
  let(:new_copyright_title) { "New Copyright / License Title"}
  after do
    apo.destroy
  end
  context "logged in user" do
    before do
      login user
      visit edit_admin_policy_path(apo)        
    end
    after { user.delete }
    context "authorized user logged in" do
      let(:user) { FactoryGirl.create(:editor) }
      before do
        select "discover", :from => "perm_public"
        select "**Remove**", :from => "perm_repositoryAdmin"
        select "repositoryReader", :from => "new_group_name"
        select "read", :from => "new_group_perm"
        fill_in "admin_policy_default_license_title", :with => new_copyright_title
        click_button "update_admin_policy_button"
      end
      it "should update the admin policy object appropriately" do
        page.should have_content(I18n.t('dul_hydra.admin_policies.messages.updated'))
        edited_apo = AdminPolicy.find(apo.id)
        edited_apo.default_permissions.should include(DulHydra::Permissions::PUBLIC_DISCOVER_ACCESS)
        edited_apo.default_permissions.should_not include(DulHydra::Permissions::ADMIN_GROUP_ACCESS)
        edited_apo.default_permissions.should include(DulHydra::Permissions::READER_GROUP_ACCESS)
        edited_apo.default_license_title.should == new_copyright_title    
      end
    end
    context "unauthorized user logged in" do
      let(:user) { FactoryGirl.create(:reader) }
      it "should return unauthorized status" do 
        page.driver.browser.last_response.status.should be(403)
      end
    end
  end
end
