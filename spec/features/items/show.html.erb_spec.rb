require 'spec_helper'

describe "show.html.erb" do
  subject { page }
  let(:item) { FactoryGirl.create(:item_in_collection_has_part_has_apo) }
  before { visit item_path(item) }
  after do
    item.admin_policy.delete
    item.parts.each { |p| p.delete }
    item.collection.delete
    item.reload # work around https://github.com/projecthydra/active_fedora/issues/36
    item.delete
  end
  it "should display the PID, title and identifier" do
    expect(subject).to have_content(item.pid)
    expect(subject).to have_content(item.title.first)
    expect(subject).to have_content(item.identifier.first)
  end
  it "should have links to datastreams" do
    item.datastreams.each_key do |dsid|
      expect(subject).to have_link(dsid)
    end
  end
  it "should have links to parent and child objects" do
    expect(subject).to have_link(item.parts.first.pid, :href => item_path(item.parts.first)) 
    expect(subject).to have_link(item.collection.pid, :href => collection_path(item.collection))
  end
end
