require 'spec_helper'

describe "datastreams/index.html.erb" do
  subject { page }
  let(:object) { FactoryGirl.create(:collection_public_read) }
  before { visit datastreams_path(object) }
  after { object.delete }
  it "should display a list of the object's datastreams" do
    object.datastreams.each do |dsid, ds|
      expect(subject).to have_content(dsid)
      expect(subject).to have_link(dsid, :href => datastream(object, dsid)) unless ds.profile.empty?
    end
  end
end
