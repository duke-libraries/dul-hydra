require 'spec_helper'
require 'helpers/user_helper'

describe 'export_sets/edit.html.erb' do
  let(:export_set) { FactoryGirl.create(:export_set, :pids => ["duke:1"]) }
  after { export_set.user.delete }
  it "should change the title" do
    login export_set.user
    visit edit_export_set_path(export_set)
    fill_in "Title", :with => "New Title"
    click_button "update_export_set_button"
    page.should have_content("Export set updated")
    ExportSet.find(export_set.id).title.should == "New Title"
  end
end
