require 'spec_helper'

describe "export_sets/index.html.erb", type: :feature, export_sets: true do
  let(:user) { FactoryGirl.create(:user) }
  before { login_as user }
  context "user has no bookmarks" do
    it "should not have a 'new export set' link" do
      visit export_sets_path
      expect(page).not_to have_link("New Export Set")
    end
  end
  context "user has bookmarks" do
    let(:object) { FactoryGirl.create(:test_content) }
    before do
      # object.read_users = [user.user_key]
      # object.save
      user.can :read, object
      user.bookmarks.create(document_id: object.pid)
    end
    it "should have a New Export Set->Content link" do
      visit export_sets_path
      expect(page).to have_link("Content", href: "#{new_export_set_path}?export_type=content")
    end
  end
  context "user has an existing export set" do
    let(:object) { FactoryGirl.create(:test_content) }
    let(:export_set) { ExportSet.new(user: user, pids: [object.pid], export_type: ExportSet::Types::CONTENT) }
    before do
      # object.read_users = [export_set.user.user_key]
      # object.save
      user.can :read, object
      export_set.create_archive
    end
    it "should list the export set" do
      visit export_sets_path
      expect(page).to have_link(export_set.id, :href => export_set_path(export_set))
    end
  end
end
