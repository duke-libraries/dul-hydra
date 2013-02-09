require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_views'

describe "datastreams.html.erb" do
  it_behaves_like "a DulHydra object datastreams view", :component
  it_behaves_like "a DulHydra object datastreams view", :item
  it_behaves_like "a DulHydra object datastreams view", :collection
end
