require 'spec_helper'

describe "preservation_events/index.html.erb" do
  subject { page }
  let(:object) { FactoryGirl.create(:test_content) }
  after { object.destroy }
  it "should list the preservation events associated with the object" do
    pe = object.fixity_check!
    pe.read_groups = ["public"]
    pe.save
    visit preservation_events_path(object)
    page.should have_link(pe.pid, :href => fcrepo_admin.object_path(pe))
  end
end
