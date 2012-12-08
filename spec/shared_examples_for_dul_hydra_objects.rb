require 'shared_examples_for_describables'
require 'shared_examples_for_governables'
require 'shared_examples_for_access_controllables'

shared_examples "a DulHydra object" do
  it_behaves_like "a describable object"
  it_behaves_like "a governable object"
  it_behaves_like "an access controllable object"
end
