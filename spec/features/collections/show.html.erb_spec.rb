require 'spec_helper'

describe "show.html.erb" do
  subject { page }
  let(:collection) { FactoryGirl.create(:collection_has_item_has_apo) }
  before { visit collection_path(collection) }
  after do
    collection.admin_policy.delete
    collection.items.each { |i| i.delete }
    collection.reload # work around https://github.com/projecthydra/active_fedora/issues/36
    collection.delete
  end
  it "should display the PID, title and identifier" do
    expect(subject).to have_content(collection.pid)
    expect(subject).to have_content(collection.title.first)
    expect(subject).to have_content(collection.identifier.first)
  end
  it "should have links to datastreams" do
    collection.datastreams.each_key do |dsid|
      expect(subject).to have_link(dsid)
    end
  end
  it "should have links to child objects" do
    expect(subject).to have_link(collection.items.first.pid, :href => item_path(item.parts.first)) 
  end
end
