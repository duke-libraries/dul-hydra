require 'spec_helper'

describe "users/edit.html.erb" do
  let(:user) { FactoryGirl.create(:user) }
  before { login_as user }
  after do
    user.destroy
    Warden.test_reset!
  end
  it "should render the profile" do
    visit edit_user_registration_path(user)
    expect(page).to have_content(user.user_key)
  end
end
