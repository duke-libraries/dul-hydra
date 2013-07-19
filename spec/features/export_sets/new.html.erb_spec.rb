require 'spec_helper'
require 'helpers/user_helper'

describe "export_sets/new.html.erb" do
  let(:object_read) { FactoryGirl.create(:test_content) }
  let(:object_discover) { FactoryGirl.create(:test_content) }
  let(:user) { FactoryGirl.create(:user) }
  before do
    login user
    object_read.read_users = [user.email]
    object_read.save
    object_discover.discover_users = [user.email]
    object_discover.save
  end
  after do
    object_read.delete 
    object_discover.delete 
    user.delete
  end
  it "should display a form with the user's bookmarked objects" do
    pending "Figuring out how to create bookmarks"
    visit '/catalog/?search_field=all_fields&q='
    click_button "bookmark_toggle_#{object_read.pid.sub(/:/, '-')}"
    click_button "bookmark_toggle_#{object_discover.pid.sub(/:/, '-')}"
    visit new_export_set_path
    assigns(:documents).collect {|d| d.id}.should == [object_discover.pid]
  end
end
