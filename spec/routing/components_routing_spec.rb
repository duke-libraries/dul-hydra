require 'spec_helper'
require 'support/shared_examples_for_repository_routers'

describe "components router", type: :routing, components: true do
  let(:controller) { "components" }

  include_examples "a repository object router"
  include_examples "a creatable object router"
  include_examples "a content-bearing object router"
end
