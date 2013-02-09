require 'spec_helper'
require 'support/shared_examples_helpers'
require 'application_helper'

RSpec.configure do |c|
  c.include SharedExamplesHelpers
  c.include ApplicationHelper
end

shared_examples "a DulHydra object datastreams view" do |object_sym|
  subject { page }
  let(:obj) do
    o = FactoryGirl.create(object_sym)
    o.permissions = [{:access => 'read', :type => 'group', :name => 'public'}]
    o.save!
    o
  end
  before { visit object_datastreams_path(obj) }
  after { obj.delete }
  it "should have links to all datastreams" do
    obj.datastreams.each_key do |dsid|
      expect(subject).to have_link(dsid, :href => object_datastream_path(obj, dsid))
    end
  end
end

shared_examples "a DulHydra object datastream view" do |object_sym|
  subject { page }
  let(:obj) do
    o = FactoryGirl.create(object_sym)
    o.permissions = [{:access => 'read', :type => 'group', :name => 'public'}]
    o.save!
    o
  end
  let(:dsid) { "DC" }
  before { visit object_datastream_path(obj, dsid) }
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
