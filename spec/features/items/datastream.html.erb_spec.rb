require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_views'

describe "items/datastream.html.erb" do
  it_behaves_like "a DulHydra object datastream view" do
    subject { page }
    let(:dsid) { "DC" }
    let(:obj) { FactoryGirl.create(:item_public_read) }
    let(:content_path) { item_datastream_content_path(obj, dsid) }
    before { visit item_datastream_path(obj, dsid) }
    after { obj.delete }
  end
end
