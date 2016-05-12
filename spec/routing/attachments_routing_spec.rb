require 'spec_helper'
require 'support/shared_examples_for_repository_routers'

describe "attachments router", type: :routing, attachments: true do
  let(:controller) { "attachments" }

  include_examples "a repository object router"
  include_examples "a creatable object router"
  include_examples "a content-bearing object router"
end
