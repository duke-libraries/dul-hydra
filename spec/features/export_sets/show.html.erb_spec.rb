require 'spec_helper'

describe "export_sets/show.html.erb", type: :feature, export_sets: true do
  let(:object) { FactoryGirl.create(:test_content) }
  let(:export_set) { FactoryGirl.create(:content_export_set, :pids => [object.pid], :title => "Test Export Set") }
  before { login_as(export_set.user, :scope => :user, :run_callbacks => false) }
  it "should display information about the export set" do
    visit export_set_path(export_set)
    expect(page).to have_content(export_set.title)
  end
  context "archive has been generated" do
    before { export_set.create_archive }
    it "should be able to delete the archive" do
      skip
      visit export_set_path(export_set)
      click_link "export_set_archive_delete"
      expect(page).to have_content("Archive deleted.")
      expect(export_set.reload.archive_file_name).to be_nil
    end
  end
  context "archive has not been generated (or was deleted)" do
    it "should be able to (re-)generate the archive" do
      skip
      visit export_set_path(export_set)
      click_link "export_set_archive_create"
      expect(page).to have_content("Archive created.")
      expect(export_set.reload.archive_file_name).not_to be_nil
    end
  end
end
