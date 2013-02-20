require 'spec_helper'

describe "catalog/datastreams/index.html.erb" do
  subject { page }
  before { visit catalog_datastreams_path(object) }
  after { object.delete }
  let(:object) { FactoryGirl.create(:collection_public_read) }
  it "should link to all datastreams" do
    object.datastreams.reject { |dsid, ds| ds.profile.empty? }.each do |dsid, ds|
      expect(subject).to have_link(dsid, :href => catalog_datastream_path(object, dsid))
    end
  end
end
