require 'spec_helper'
require 'helpers/user_helper'

describe "export_sets/new.html.erb" do
  let(:object) { FactoryGirl.create(:test_content) }
  let(:user) { FactoryGirl.create(:user) }
  before do
    login user
    visit catalog_path(object)
    click_button "bookmark_toggle_#{object.pid.sub(/:/, '-')}"
  end
  after do
    object.delete 
    user.delete
  end
  it "should display a form with the user's bookmarked objects" do
    visit new_export_set_path
    page.should have_content(object.pid)
  end
end
