require 'spec_helper'
require 'helpers/user_helper'

describe "Users" do
  let!(:user) { FactoryGirl.create(:user) }
  before { login user }
  after { user.delete }
  it "should be able to login" do
    # visit new_user_session_path
    # fill_in "Email", :with => @email
    # fill_in "Password", :with => @password
    # click_button "Sign in"
    page.should have_content "Signed in successfully"
    page.should have_link("Log Out", :href => destroy_user_session_path)
  end
  it "should be able to logout" do
    # visit new_user_session_path
    # fill_in "Email", :with => @email
    # fill_in "Password", :with => @password
    # click_button "Sign in"
    click_link "Log Out"
    page.should have_content "Signed out successfully"
    page.should have_link("Login", :href => new_user_session_path)
  end

end
