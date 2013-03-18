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
end
