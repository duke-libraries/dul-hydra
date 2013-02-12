require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_views'

describe "components/datastreams.html.erb" do
  it_behaves_like "a DulHydra object datastreams view" do
    subject { page }
    let(:obj) { FactoryGirl.create(:component_public_read) }
    before { visit component_datastreams_path(obj) }
    after { obj.delete }
  end
end
