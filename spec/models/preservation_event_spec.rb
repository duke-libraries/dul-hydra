require 'spec_helper'
require 'shared_examples_for_governables'
require 'shared_examples_for_access_controllables'

shared_examples "a preservation event having required data" do
  its(:for_object) { should be_kind_of(DulHydra::Models::HasPreservationEvents) }
  its(:event_id_type) { should_not be_nil }
  its(:event_id_value) { should_not be_nil }
  its(:event_date_time) { should_not be_nil }
  its(:event_type) { should_not be_nil }
end

shared_examples "a preservation event having a success outcome" do
  its(:event_outcome) { should eq(PreservationEvent::SUCCESS) }
  its(:success?) { should be_true }
  its(:failure?) { should be_false }
end

shared_examples "a preservation event having a failure outcome" do
  its(:event_outcome) { should eq(PreservationEvent::FAILURE) }
  its(:success?) { should be_false }
  its(:failure?) { should be_true }
end

shared_examples "a fixity check preservation event" do # |dsID|
  it_should_behave_like "a preservation event having required data"
  its(:fixity_check?) { should be_true }
  its(:event_type) { should eq(PreservationEvent::FIXITY_CHECK) }
  its(:event_id_type) { should eq(PreservationEvent::UUID) }
  its(:linking_object_id_type) { should eq(PreservationEvent::DATASTREAM) }
  # its(:linking_object_id_value) { should eq("#{subject.for_object.internal_uri}/datastreams/#{dsID}?asOfDateTime=%s" % subject.for_object.datastreams[dsID].dsCreateDate.strftime("%Y-%m-%dT%H:%M:%S.%LZ")) }
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
    after { obj.delete }
    context "success" do
      let(:obj) { FactoryGirl.create(:component_with_content) }
      it_should_behave_like "a fixity check preservation event"
      it_should_behave_like "a preservation event having a success outcome"
    end
    context "failure" do
      before do
        # Override datastream method #dsChecksumValid to always return false
        class << obj.datastreams["content"]
          def dsChecksumValid
            false
          end
        end
      end
      let(:obj) { FactoryGirl.create(:component_with_content) }
      it_should_behave_like "a fixity check preservation event"
      it_should_behave_like "a preservation event having a failure outcome"
    end
  end

end
