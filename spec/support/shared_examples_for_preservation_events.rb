require 'spec_helper'

shared_examples "a valid preservation event" do
  it "should behave like a valid event" do
    subject.event_date_time.should be_present
    subject.event_id_type.should eq(PreservationEvent::UUID)
    subject.event_id_value.should be_present
    PreservationEvent::EVENT_TYPES.should include(subject.event_type)
    PreservationEvent::EVENT_OUTCOMES.should include(subject.event_outcome)
  end
end

shared_examples "a valid object preservation event" do
  it_should_behave_like "a valid preservation event"
  it "should behave like an object event" do
    subject.for_object.should be_kind_of(DulHydra::Models::HasPreservationEvents)
    subject.should be_for_object
    subject.linking_object_id_type.should eq(PreservationEvent::OBJECT)
    subject.linking_object_id_value.should eq(subject.for_object.pid)
  end
end

shared_examples "a preservation event having a success outcome" do
  it "should behave like a success event" do
    subject.event_outcome.should eq(PreservationEvent::SUCCESS)
    subject.should be_success
    subject.should_not be_failure
  end
end

shared_examples "a preservation event having a failure outcome" do
  it "should behave like a failure event" do
    subject.event_outcome.should eq(PreservationEvent::FAILURE)
    subject.should_not be_success
    subject.should be_failure
  end
end

shared_examples "a fixity check preservation event" do
  it_should_behave_like "a valid object preservation event"
  it "should behave like a fixity check" do
    subject.should be_fixity_check
    subject.event_type.should eq(PreservationEvent::FIXITY_CHECK)
  end
end

shared_examples "a fixity check success preservation event" do
  it_should_behave_like "a fixity check preservation event"
  it_should_behave_like "a preservation event having a success outcome"
end

shared_examples "a fixity check failure preservation event" do
  it_should_behave_like "a fixity check preservation event"
  it_should_behave_like "a preservation event having a failure outcome"
end

