require 'spec_helper'
require 'helpers/user_helper'

describe "export_sets/new.html.erb" do
  let(:object_read) { FactoryGirl.create(:component_with_content) }
  let(:object_discover) { FactoryGirl.create(:component_with_content) }
  let(:user) { FactoryGirl.create(:user) }
  before do
    object_read.read_users = [user.username]
    object_read.save
    object_discover.discover_users = [user.username]
    object_discover.save
    user.bookmarks.create(:document_id => object_read.pid)
    user.bookmarks.create(:document_id => object_discover.pid)
    login user
  end
  after do
    object_read.delete 
    object_discover.delete 
    user.delete
  end
  it "should display a form with the user's bookmarked objects" do
    visit new_export_set_path
    page.should_not have_content(object_discover.pid)
    page.should have_content(object_read.pid)
  end
end
