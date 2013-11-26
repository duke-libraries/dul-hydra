require 'spec_helper'

describe "objects/new.html.erb" do
  let(:user) { FactoryGirl.create(:user) }
  before do
    DulHydra.creatable_models = ["AdminPolicy", "Collection"]
    ability = Ability.new(user)
    ability.can(:create, [AdminPolicy, Collection])
    user.stub(:ability).and_return(ability)
    login_as user
  end
  after do 
    user.delete
    Warden.test_reset!
  end
  context "AdminPolicy" do
    after { AdminPolicy.delete_all }
    it "should create an AdminPolicy" do
      pending
      visit new_object_path('admin_policy')
      fill_in 'Title', with: 'New Admin Policy'
      fill_in 'Description', with: 'Taking over the world!'
      click_button 'Save'
      expect(page).to have_text("New AdminPolicy successfully created")
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
      pending
      visit new_object_path('collection')
      select @admin_policies[1].pid, from: "object[admin_policy_id]"
      fill_in 'Title', with: 'New Collection'
      click_button 'Save'
      expect(page).to have_text("New Collection successfully created")
    end
  end
end
