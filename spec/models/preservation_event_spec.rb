require 'spec_helper'
require 'shared_examples_for_governables'
require 'shared_examples_for_access_controllables'

shared_examples "a preservation event having required data" do
  its(:event_id_type) { should_not be_nil }
  its(:event_id_value) { should_not be_nil }
  its(:event_date_time) { should_not be_nil }
  its(:event_type) { should_not be_nil }
end

shared_examples "a preservation event having a success outcome" do
  its(:event_outcome) { should eq(PreservationEvent::SUCCESS) }
end

shared_examples "a preservation event having a failure outcome" do
  its(:event_outcome) { should eq(PreservationEvent::FAILURE) }
end

shared_examples "a fixity check preservation event" do
  it_should_behave_like "a preservation event having required data"
  its(:fixity_check?) { should be_true }
  its(:event_type) { should eq(PreservationEvent::FIXITY_CHECK) }
  its(:event_id_type) { should eq(PreservationEvent::UUID) }
  its(:linking_object_id_type) { should eq(PreservationEvent::DATASTREAM) }
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
    context "success" do
      let(:obj) { FactoryGirl.create(:component_with_content) }
      after { obj.delete }
      subject { PreservationEvent.validate_checksum(obj, "content") }
      it_should_behave_like "a fixity check preservation event"
      it_should_behave_like "a preservation event having a success outcome"
    end
    context "failure" do
      let(:obj) { FactoryGirl.create(:component_with_content) }
      after { obj.delete }
      before do
        # Override datastream method #dsChecksumValid to always return false
        class << obj.datastreams["content"]
          def dsChecksumValid
            false
          end
        end
      end
      subject { PreservationEvent.validate_checksum(obj, "content") }
      it_should_behave_like "a fixity check preservation event"
      it_should_behave_like "a preservation event having a failure outcome"
    end
  end

end
