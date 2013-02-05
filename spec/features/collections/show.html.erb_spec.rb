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
  it { should have_content(collection.pid) }
  it { should have_content(collection.title.first) } 
  it { should have_content(collection.identifier.first) }
  it { should have_link("DC") }
  it { should have_link("RELS-EXT") }
  it { should have_link("descMetadata") }
  it { should have_link(collection.items.first.pid, :href => item_path(collection.items.first)) }
  
end
