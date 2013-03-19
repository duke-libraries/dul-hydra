require 'spec_helper'
require 'helpers/user_helper'

describe "export_sets/show.html.erb" do
  let(:object) { FactoryGirl.create(:test_content) }
  let(:user) { FactoryGirl.create(:user) }
  let(:export_set) { ExportSet.new }
  before do
    login user
    export_set.title = "Test Export Set"
    export_set.user = user
    export_set.pids = [object.pid]
    export_set.create_archive
  end
  after do
    object.delete 
    user.delete
  end
  it "should display information about the export set" do
    visit export_set_path(export_set)
    page.should have_content(export_set.title)
  end
  context "archive has been generated" do
    it "should be able to delete the archive" do
      visit export_set_path(export_set)
      click_link "Delete Archive"
      page.should have_content("Archive deleted.")
      export_set.reload.archive_file_name.should be_nil
    end
  end
  context "archive has not been generated or was deleted" do
    before do
      export_set.archive = nil
      export_set.save
    end
    it "should be able to (re-)generate the archive" do
      visit export_set_path(export_set)
      click_link "Create Archive"
      page.should have_content("Archive created.")
      export_set.reload.archive_file_name.should_not be_nil
    end
  end
end
