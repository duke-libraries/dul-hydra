require 'spec_helper'
require 'shared_examples_for_governables'
require 'shared_examples_for_access_controllables'
require 'shared_examples_for_preservation_events'

# Override datastream method #dsChecksumValid to always return false
def ds_checksum_valid_false(ds)
  class << ds
    def dsChecksumValid; false; end
  end
end

describe PreservationEvent do

  it_behaves_like "an access controllable object"
  it_behaves_like "a governable object"

  context "#new" do
    let(:obj) { PreservationEvent.new }
    it "should have an eventMetadata datastream" do
      obj.datastreams["eventMetadata"].should be_kind_of(DulHydra::Datastreams::PremisEventDatastream)
    end
  end

  context "::validate_checksum" do
    subject { PreservationEvent.validate_checksum(obj, "content") }
    after { obj.destroy }
    context "success" do
      let(:obj) { FactoryGirl.create(:component_with_content) }
      it_should_behave_like "a fixity check success preservation event"
    end
    context "failure" do
      before { ds_checksum_valid_false(obj.datastreams["content"]) }
      let(:obj) { FactoryGirl.create(:component_with_content) }
      it_should_behave_like "a fixity check failure preservation event"
    end
  end

  context "::validate_checksum!" do
    subject { PreservationEvent.validate_checksum!(obj, "content") }
    after { obj.destroy }
    context "success" do
      let(:obj) { FactoryGirl.create(:component_with_content) }
      it_should_behave_like "a fixity check success preservation event"
    end
    context "failure" do
      before { ds_checksum_valid_false(obj.datastreams["content"]) }
      let(:obj) { FactoryGirl.create(:component_with_content) }
      it_should_behave_like "a fixity check failure preservation event"
    end
  end

end
