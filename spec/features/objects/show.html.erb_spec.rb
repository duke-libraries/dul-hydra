require 'spec_helper'
require 'helpers/user_helper'

describe "objects/show.html.erb" do
  let(:user) { FactoryGirl.create(:user) }
  before do
    object.read_users = [user.to_s]
    object.save
    login user 
  end
  after(:each) do
    logout user
    object.delete
  end
  after(:all) { user.delete }
  context "object is describable" do
    let(:object) { FactoryGirl.create(:item) }
    it "should display the descriptive metadata" do
      visit object_path(object)
      page.should have_css("div#tab_descriptive_metadata")
    end
    context "the user has edit permission" do
      before do
        object.edit_users = [user.user_key]
        object.save
      end
      it "should link to the edit page" do
        visit object_path(object)
        page.should have_link("Edit", href: record_edit_path(object))
      end
    end
  end
  context "object has preservation events" do
    let(:object) { FactoryGirl.create(:test_model) }
    it "should show the object's last fixity check" do
      visit object_path(object)
      page.should have_content("Last Fixity Check")
    end
  end
  context "object has content" do

  end
  context "object has children" do
    let(:object) { FactoryGirl.create(:item) }
    let(:child) { FactoryGirl.create(:component) }
    before do
      child.read_users = [user.to_s]
      child.parent = object
      child.save
    end
    after { child.delete }
    it "should render the object's children" do
      visit object_path(object)
      page.should have_css("div#tab_components")
      page.should have_xpath("//a[@href=\"#{object_path(child)}\"]")
    end
  end
end
