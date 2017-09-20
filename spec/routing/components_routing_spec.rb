require 'spec_helper'
require 'support/shared_examples_for_repository_routers'

describe "components router", type: :routing, components: true do
  it_behaves_like "a repository object router" do
    let(:controller) { "components" }
  end
  it_behaves_like "a content-bearing object router" do
    let(:controller) { "components" }
  end

  specify {
    expect(get: '/components/duke:1/intermediate').to route_to(controller: 'components', action: 'intermediate', id: 'duke:1')
  }

  specify {
    expect(get: '/components/duke:1/stream').to route_to(controller: 'components', action: 'stream', id: 'duke:1')
  }

  specify {
    expect(get: '/components/duke:1/captions').to route_to(controller: 'components', action: 'captions', id: 'duke:1')
  }

end
