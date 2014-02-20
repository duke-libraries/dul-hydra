require 'spec_helper'

describe "objects/new.html.erb", objects: true do
  let(:user) { FactoryGirl.create(:user) }
  before do
    DulHydra.creatable_models = ["AdminPolicy", "Collection"]
    User.any_instance.stub(:superuser?).and_return(true)
    login_as user
  end
  after do 
    ActiveFedora::Base.destroy_all
    user.destroy
    Warden.test_reset!
  end
  it "should create an AdminPolicy" do
    visit "#{new_object_path}?type=AdminPolicy"
    fill_in 'Title', with: 'New Admin Policy'
    fill_in 'Description', with: 'Taking over the world!'
    click_button 'Save'
    expect(page).to have_text("Object was successfully created")
  end
  context "Collection" do
    before { @admin_policy = FactoryGirl.create(:public_discover_policy) }
    it "should create a collection" do
      visit "#{new_object_path}?type=Collection"
      fill_in 'Title', with: 'New Collection'
      select @admin_policy.title, from: 'admin_policy_id'
      click_button 'Save'
      expect(page).to have_text("Object was successfully created")
    end
  end
end
