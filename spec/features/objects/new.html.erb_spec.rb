require 'spec_helper'

describe "objects/new.html.erb", objects: true do
  let(:user) { FactoryGirl.create(:user) }
  before do
    DulHydra.creatable_models = ["AdminPolicy", "Collection"]
    User.any_instance.stub(:superuser?).and_return(true)
    login_as user
  end
  after do 
    user.destroy
    Warden.test_reset!
  end
  context "AdminPolicy" do
    after { AdminPolicy.delete_all }
    it "should create an AdminPolicy" do
      visit "#{new_object_path}?type=AdminPolicy"
      fill_in 'Title', with: 'New Admin Policy'
      fill_in 'Description', with: 'Taking over the world!'
      click_button 'Save'
      expect(page).to have_text("Object was successfully created")
    end
  end
  context "Collection" do
    before do
      @admin_policies = FactoryGirl.create_list(:admin_policy, 3)
      @admin_policies.each do |apo|
        apo.title = apo.pid
        apo.read_users = [user.to_s]
        apo.save
      end
    end
    after do
      Collection.delete_all
      AdminPolicy.delete_all
    end
    it "should create a collection" do
      visit "#{new_object_path}?type=Collection&admin_policy_id=#{@admin_policies.first.pid}"
      fill_in 'Title', with: 'New Collection'
      click_button 'Save'
      expect(page).to have_text("Object was successfully created")
    end
  end
end
