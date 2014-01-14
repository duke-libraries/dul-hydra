require 'spec_helper'

describe 'export_sets/edit.html.erb', export_sets: true do
  let(:export_set) { FactoryGirl.create(:content_export_set, :pids => ["duke:1"]) }
  before { login_as export_set.user }
  after do
    export_set.user.destroy
    Warden.test_reset!
  end
  it "should change the title" do
    visit edit_export_set_path(export_set)
    fill_in "Title", :with => "New Title"
    click_button "update_export_set_button"
    ExportSet.find(export_set.id).title.should == "New Title"
  end
end
