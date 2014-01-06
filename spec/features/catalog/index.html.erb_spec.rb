require 'spec_helper'
require 'helpers/user_helper'

describe "catalog/index.html.erb" do
  let(:user) { FactoryGirl.create(:user) }
  let(:object) { FactoryGirl.create(:component_with_content) }
  before(:each) { login user }
  after(:each) do
    logout user
    user.delete
    object.delete
  end
  context "search options" do
    before do
      object.discover_groups = ["public"]
      object.save
      visit catalog_index_path
      select "PID", :from => "search_field"
      fill_in "q", :with => object.pid
      click_button "search"
    end
    it "should allow searching by PID" do
      page.should have_content(object.title.first)
    end
  end
  context "search results" do
    context "general discovery" do
      before do
        object.discover_groups = ["public"]
        object.save!
        visit catalog_index_path
        fill_in "q", :with => object.title.first
        click_button "search"
      end
      it "should display thumbnail, title, and identifier" do
        page.should have_xpath("//img[@src = \"#{thumbnail_object_path(object)}\"]")
        page.should have_content(object.identifier.first)
        page.should have_content(object.title.first)
      end
    end
    context "user does not have read permission on object" do
      before do
        object.discover_groups = ["public"]
        object.save!
        visit catalog_index_path
        fill_in "q", :with => object.title.first
        click_button "search"
      end
      it "should not link to download or show view" do
        page.should_not have_xpath("//a[@href = \"#{object_path(object)}\"]")
        page.should_not have_xpath("//a[@href = \"#{download_object_path(object)}\"]")
      end
    end
    context "user has read permission on object" do
      before do
        object.read_groups = ["public"]
        object.save!
        visit catalog_index_path
        fill_in "q", :with => object.title.first
        click_button "search"
      end
      it "should link to download and show view" do
        pending "Figure out why this test is failing"
        page.should have_xpath("//a[@href = \"#{object_path(object)}\"]")
        page.should have_xpath("//a[@href = \"#{download_object_path(object)}\"]")
      end
    end
  end
end
