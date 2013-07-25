require 'spec_helper'
require 'helpers/user_helper'

describe "export_sets/index.html.erb" do
  let!(:user) { FactoryGirl.create(:user) }
  before { login user }
  after { user.delete }
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
    let(:export_set) { ExportSet.new }
    before do
      export_set.user = user
      export_set.pids = [object.pid]
      export_set.create_archive
    end
    after { object.delete }
    it "should list the export set" do
      visit export_sets_path
      page.should have_link(export_set.id, :href => export_set_path(export_set))
    end        
  end
end
