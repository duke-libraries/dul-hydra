require 'spec_helper'

describe "admin_policies/new.html.erb", admin_policies: true do
  let(:user) { FactoryGirl.create(:user) }
  before do
    DulHydra.stub(:creatable_models).and_return(["AdminPolicy"])
    DulHydra.stub(:ability_group_map).and_return({"AdminPolicy" => {create: "admin_policy_creators"}}.with_indifferent_access)
    User.any_instance.stub(:groups).and_return(["admin_policy_creators"])    
    login_as user
  end
  after do 
    ActiveFedora::Base.destroy_all
    user.destroy
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
