require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_views'

describe "collections/datastreams.html.erb" do
  it_behaves_like "a DulHydra object datastreams view" do
    subject { page }
    let(:obj) { FactoryGirl.create(:collection_public_read) }
    before { visit collection_datastreams_path(obj) }
    after { obj.delete }
  end
end
