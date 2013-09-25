require 'spec_helper'
require 'helpers/user_helper'

describe "catalog/show.html.erb" do
  before { login user }
  after { user.delete }
  context "admin policy" do
    let(:user) { FactoryGirl.create(:user) }
    let(:apo) { FactoryGirl.create(:admin_policy) }
    after { apo.delete }
    context "display default permissions" do
      before do
        apo.permissions = [ DulHydra::Permissions::PUBLIC_READ_ACCESS ]
        apo.default_permissions = [ DulHydra::Permissions::REGISTERED_READ_ACCESS ]
        apo.save!
        visit catalog_path(apo)
      end
      it "should display the default permissions" do
        page.should have_content('registered')
      end
    end
    context "display edit link" do
      before do
        visit catalog_path(apo)
      end
      context "user has edit permissions" do
        let!(:user) { FactoryGirl.create(:editor) }
        it "should display an edit link" do
          page.should have_link("Edit")
        end
      end
      context "user does not have edit permissions" do
        let!(:user) { FactoryGirl.create(:reader) }
        it "should display not an edit link" do
          page.should_not have_link("Edit")
        end        
      end
    end
  end

end
