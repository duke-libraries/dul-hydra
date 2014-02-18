require 'spec_helper'

describe 'export_sets/edit.html.erb', export_sets: true do
  before { login_as export_set.user }
  after do
    export_set.user.destroy
    export_set.destroy
    Warden.test_reset!
  end
  context "edit content export set title" do
    let(:export_set) { FactoryGirl.create(:content_export_set, :pids => ["duke:1"]) }
    it "should change the title" do
      visit edit_export_set_path(export_set)
      fill_in "Title", :with => "New Title"
      click_button "update_export_set_button"
      ExportSet.find(export_set.id).title.should == "New Title"
    end
  end
  context "descriptive metadata export set edit form" do
    let(:export_set) { FactoryGirl.create(:descriptive_metadata_export_set_with_pids_with_csv_col_sep) }
    it "should contain a warning about editing csv_col_sep" do
      visit edit_export_set_path(export_set)
      expect(page).to have_text(I18n.t('dul_hydra.export_sets.alerts.warn_change_csv_col_sep'))
    end
  end
end
