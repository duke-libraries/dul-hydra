require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_views'

describe "items/datastreams.html.erb" do
  it_behaves_like "a DulHydra object datastreams view" do
    subject { page }
    after { obj.delete }
    let(:obj) { FactoryGirl.create(:item_public_read) }
    before { visit item_datastreams_path(obj) }
  end
end
