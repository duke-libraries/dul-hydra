require 'spec_helper'

describe "datastreams.html.erb" do
  subject { page }
  let(:component) { FactoryGirl.create(:component_has_apo) }
  before { visit component_datastreams_path(component) }
  after do
    component.admin_policy.delete
    component.delete
  end
  it "should have links to all datastreams" do
    component.datastreams.each_key do |dsid|
      expect(subject).to have_link(dsid, :href => component_datastream_path(component, dsid))
    end
  end
end
