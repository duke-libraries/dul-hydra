require 'spec_helper'

describe "export_sets/index.html.erb", export_sets: true do
  let(:user) { FactoryGirl.create(:user) }
  before { login_as user }
  after do
    user.destroy
    Warden.test_reset!
  end
  context "user has no bookmarks" do
    it "should not have a 'new export set' link" do
      visit export_sets_path
      page.should_not have_link("New Export Set")
    end
  end
  context "user has bookmarks" do
    let(:object) { FactoryGirl.create(:test_content) }
    after { object.delete }
    it "should have a 'new export set' link" do
      pending "Figuring out why Capybara doesn't find the control"
      visit catalog_path(object)
      find(:css, "#bookmark_toggle_#{object.pid.sub(/:/, '-')}").set(true)
      visit export_sets_path
      page.should have_link("New Export Set")
    end    
  end
  context "user has an existing export set" do
    let(:object) { FactoryGirl.create(:test_content) }
    let(:export_set) { ExportSet.new(user: user, pids: [object.pid], export_type: ExportSet::Types::CONTENT) }
    before do
      object.read_users = [export_set.user.user_key]
      object.save
      export_set.create_archive
    end
    after { object.delete }
    it "should list the export set" do
      visit export_sets_path
      page.should have_link(export_set.id, :href => export_set_path(export_set))
    end        
  end
end
