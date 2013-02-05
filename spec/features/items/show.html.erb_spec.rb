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
  it { should have_content(item.pid) }
  it { should have_content(item.title.first) } 
  it { should have_content(item.identifier.first) }
  it { should have_link("DC") }
  it { should have_link("RELS-EXT") }
  it { should have_link("descMetadata") }
  it { should have_link(item.parts.first.pid, :href => component_path(item.parts.first)) }
  it { should have_link(item.collection.pid, :href => collection_path(item.collection)) }
  
end
