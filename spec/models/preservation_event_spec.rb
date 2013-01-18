require 'spec_helper'
require 'shared_examples_for_governables'
require 'shared_examples_for_access_controllables'

describe PreservationEvent do

  it_behaves_like "an access controllable object"
  it_behaves_like "a governable object"

  context "new" do
    let(:obj) { PreservationEvent.new }
    it "should have an eventMetadata datastream" do
      obj.datastreams["eventMetadata"].should be_kind_of(DulHydra::Datastreams::PremisEventDatastream)
    end
  end

end
