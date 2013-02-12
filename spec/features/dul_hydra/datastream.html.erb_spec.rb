require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_views'

describe "dul_hydra/datastream.html.erb" do
  let!(:dsid) { "DC" }
  after { obj.delete }
  # Component
  it_behaves_like "a DulHydra object datastream view" do
    let(:obj) { FactoryGirl.create(:component_public_read) }
    let(:content_path) { component_datastream_content_path(obj, dsid) }
    before { visit component_datastream_path(obj, dsid) }
  end
  # Item
  it_behaves_like "a DulHydra object datastream view" do
    let(:obj) { FactoryGirl.create(:item_public_read) }
    let(:content_path) { item_datastream_content_path(obj, dsid) }
    before { visit item_datastream_path(obj, dsid) }
  end
  # Collection
  it_behaves_like "a DulHydra object datastream view" do
    let(:obj) { FactoryGirl.create(:collection_public_read) }
    let(:content_path) { collection_datastream_content_path(obj, dsid) }
    before { visit collection_datastream_path(obj, dsid) }
  end
end
