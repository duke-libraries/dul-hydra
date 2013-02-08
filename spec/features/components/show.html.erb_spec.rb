require 'spec_helper'

describe "show.html.erb" do
  subject { page }
  let(:component) { FactoryGirl.create(:component_part_of_item_with_content_has_apo) }
  before { visit component_path(component) }
  after do
    component.admin_policy.delete
    component.item.delete
    component.reload # work around https://github.com/projecthydra/active_fedora/issues/36
    component.delete
  end
  it "should display the PID, title and identifier" do
    expect(subject).to have_content(component.pid)
    expect(subject).to have_content(component.title.first)
    expect(subject).to have_content(component.identifier.first)
  end
  it "should have links to datastreams" do
    component.datastreams.each_key do |dsid|
      expect(subject).to have_link(dsid, :href => component_datastream_path(component, dsid))
    end
  end  
  it "should have a link to its parent object" do
    expect(subject).to have_link(component.item.pid, :href => item_path(component.item))
  end
end
