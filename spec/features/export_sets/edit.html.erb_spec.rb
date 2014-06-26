require 'spec_helper'

describe 'export_sets/edit.html.erb', export_sets: true do
  let(:user) { FactoryGirl.create(:user) }
  before { login_as user }
  context "edit content export set title" do
    let(:export_set) do
      ExportSet.new.tap do |es|
        es.export_type = ExportSet::Types::CONTENT
        es.user = user
        es.pids = ["duke:1"]
        es.save!
      end
    end
    it "should change the title" do
      visit edit_export_set_path(export_set)
      fill_in "Title", :with => "New Title"
      click_button "update_export_set_button"
      ExportSet.find(export_set.id).title.should == "New Title"
    end
  end
  context "descriptive metadata export set edit form" do
    let(:export_set) do
      ExportSet.new.tap do |es|
        es.export_type = ExportSet::Types::DESCRIPTIVE_METADATA
        es.user = user
        es.pids = ["foo:bar"]
        es.csv_col_sep = "comma"
        es.save!
      end
    end 
    it "should contain a warning about editing csv_col_sep" do
      visit edit_export_set_path(export_set)
      expect(page).to have_text(I18n.t('dul_hydra.export_sets.alerts.warn_change_csv_col_sep'))
    end
  end
end
