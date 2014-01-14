require 'spec_helper'

describe "export_sets/new.html.erb", export_sets: true do

  let(:user) { FactoryGirl.create(:user) }

  after do
    user.destroy
    Warden.test_reset!
  end

  context "export_type == 'content'" do
    let(:object_read) { FactoryGirl.create(:component_with_content) }
    let(:object_discover) { FactoryGirl.create(:component_with_content) }
    before do
      object_read.read_users = [user.username]
      object_read.save
      object_discover.discover_users = [user.username]
      object_discover.save
      user.bookmarks.create(:document_id => object_read.pid)
      user.bookmarks.create(:document_id => object_discover.pid)
      DulHydra.ability_group_map = {"Component" => {download: "component_download"}}.with_indifferent_access
      user.stub(:groups).and_return(["component_download"])
      login_as user
    end
    after do
      object_read.delete 
      object_discover.delete 
    end
    it "should display a form with content-bearing bookmarked objects on which the user has download permission" do
      visit "#{new_export_set_path}?export_type=#{ExportSet::Types::CONTENT}"
      page.should_not have_content(object_discover.pid)
      page.should have_content(object_read.pid)
    end
  end

  context "export_type == 'descriptive_metadata'" do
    let(:object_read) { FactoryGirl.create(:item) }
    let(:object_discover) { FactoryGirl.create(:item) }
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
    end
    it "should display a form with bookmarked objects on which the user has read permission" do
      visit "#{new_export_set_path}?export_type=#{ExportSet::Types::DESCRIPTIVE_METADATA}"
      page.should_not have_content(object_discover.pid)
      page.should have_content(object_read.pid)
    end    
  end

end
