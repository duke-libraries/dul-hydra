require 'spec_helper'
require 'support/shared_examples_for_repository_routers'

describe "components router", components: true do
  it_behaves_like "a repository object router" do
    let(:controller) { "components" }
  end
  it_behaves_like "a content-bearing object router" do
    let(:controller) { "components" }
  end
end
