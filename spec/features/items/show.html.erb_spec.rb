require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_views'

describe "show.html.erb" do

  subject { page }
  let(:item) { FactoryGirl.create(:item_in_collection_with_parts) }
  before { visit item_path(item) }
  after do
    item.parts.each { |p| p.delete }
    item.collection.delete
    item.delete
  end
  #it_behaves_like "a DulHydra show view", item
  it { should have_content(item.pid) }
  it { should have_content(item.title.first) } 
  it { should have_content(item.identifier.first) }
  it { should have_link("DC") }
  it { should have_link("RELS-EXT") }
  
end
