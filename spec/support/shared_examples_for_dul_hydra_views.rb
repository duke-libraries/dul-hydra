require 'spec_helper'
require 'support/shared_examples_helpers'
require 'application_helper'

RSpec.configure do |c|
  c.include SharedExamplesHelpers
  c.include ApplicationHelper
end

shared_examples "a DulHydra object datastreams view" do
  subject { page }
  before do
    obj.permissions = [{:access => 'read', :type => 'group', :name => 'public'}]
    obj.save!
    visit object_datastreams_path(obj)
  end
  after { obj.delete }
  it "should have links to all datastreams" do
    obj.datastreams.each do |dsid, ds|
      expect(subject).to have_link(dsid, :href => object_datastream_path(obj, dsid)) unless ds.profile.empty?
    end
  end
end

shared_examples "a DulHydra object datastream view" do
  subject { page }
  let(:dsid) { "DC" }
  before do
    obj.permissions = [{:access => 'read', :type => 'group', :name => 'public'}]
    obj.save!
    visit object_datastream_path(obj, dsid)
  end
  after { obj.delete }
  it "should show all the attributes of the datastream profile" do
    obj.datastreams[dsid].profile.each do |key, value|
      expect(subject).to have_content(key)
      expect(subject).to have_content(value)
    end
  end
  it "should have a link to download the datastream content" do
    expect(subject).to have_link("Download Content", :href => object_datastream_content_path(obj, dsid))
  end
end
