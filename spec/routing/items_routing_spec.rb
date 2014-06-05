require 'spec_helper'
require 'support/shared_examples_for_repository_routers'

describe "items router", items: true do
  it_behaves_like "a repository object router" do
    let(:controller) { "items" }
  end
end
