require 'spec_helper'

shared_examples "a DulHydra object show view" do
  it "should display the PID, title and identifier" do
    expect(subject).to have_content(obj.pid)
    expect(subject).to have_content(obj.title.first)
    expect(subject).to have_content(obj.identifier.first)
  end
  it "should have links to datastreams" do
    obj.datastreams.each do |dsid, ds|
      expect(subject).to have_link(dsid) unless ds.profile.empty?
    end
  end  
  it "should have a link to its parent object, if relevant" do
    expect(subject).to have_link(obj.parent.pid) if obj.respond_to?(:parent)
  end
  it "should have a link to its admin policy" do
    pending
    #expect(subject).to have_link(obj.admin_policy.pid)
  end
end

shared_examples "a DulHydra object datastreams view" do
  it "should have links to all datastreams" do
    obj.datastreams.each do |dsid, ds|
      expect(subject).to have_link(dsid) unless ds.profile.empty?
    end
  end
end

shared_examples "a DulHydra object datastream view" do
  it "should show all the attributes of the datastream profile" do
    obj.datastreams[dsid].profile.each do |key, value|
      expect(subject).to have_content(key)
      expect(subject).to have_content(value)
    end
  end
  it "should have a link to download the datastream content" do
    expect(subject).to have_link("Download Content", :href => content_path)
  end
end
