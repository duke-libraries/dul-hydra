require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_views'

describe "datastream.html.erb" do
  it_behaves_like "a DulHydra object datastream view", :component
  it_behaves_like "a DulHydra object datastream view", :item
  it_behaves_like "a DulHydra object datastream view", :collection
end
