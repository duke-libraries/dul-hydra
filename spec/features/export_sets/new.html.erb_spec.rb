require 'spec_helper'

describe "export_sets/new.html.erb", type: :feature, export_sets: true do

  let(:user) { FactoryGirl.create(:user) }

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
      allow(user).to receive(:has_role?).with("Component Downloader") { true }
      login_as user
    end
    it "should display a form with content-bearing bookmarked objects on which the user has download permission" do
      visit "#{new_export_set_path}?export_type=#{ExportSet::Types::CONTENT}"
      expect(page).not_to have_content(object_discover.pid)
      expect(page).to have_content(object_read.pid)
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
      login_as user
    end
    it "should display a form with bookmarked objects on which the user has read permission" do
      visit "#{new_export_set_path}?export_type=#{ExportSet::Types::DESCRIPTIVE_METADATA}"
      expect(page).not_to have_content(object_discover.pid)
      expect(page).to have_content(object_read.pid)
    end    
  end

end
