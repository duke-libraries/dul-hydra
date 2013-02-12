require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_views'

describe "dul_hydra/datastream.html.erb" do
  it_behaves_like "a DulHydra object datastream view" do
    let(:obj) { FactoryGirl.create(:component) }
  end
  it_behaves_like "a DulHydra object datastream view" do
    let(:obj) { FactoryGirl.create(:item) }
  end
  it_behaves_like "a DulHydra object datastream view" do
    let(:obj) { FactoryGirl.create(:collection) }
  end
end
