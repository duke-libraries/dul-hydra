require 'spec_helper'

shared_examples "a valid preservation event" do
  it "should behave like a valid event" do
    subject.event_date_time.should_not be_nil
    subject.event_id_type.should eq(PreservationEvent::UUID)
    subject.event_id_value.should_not be_nil
    PreservationEvent::EVENT_TYPES.should include(subject.event_type)
    PreservationEvent::EVENT_OUTCOMES.should include(subject.event_outcome)
  end
end

shared_examples "a valid object preservation event" do
  it_should_behave_like "a valid preservation event"
  it "should behave like an object event" do
    subject.for_object.should be_kind_of(DulHydra::Models::HasPreservationEvents)
    subject.for_object?.should be_true
    subject.linking_object_id_type.should eq(PreservationEvent::OBJECT)
    subject.linking_object_id_value.should eq(subject.for_object.pid)
  end
end

shared_examples "a preservation event having a success outcome" do
  it "should behave like a success event" do
    subject.event_outcome.should eq(PreservationEvent::SUCCESS)
    subject.success?.should be_true
    subject.failure?.should be_false
  end
end

shared_examples "a preservation event having a failure outcome" do
  it "should behave like a failure event" do
    subject.event_outcome.should eq(PreservationEvent::FAILURE)
    subject.success?.should be_false
    subject.failure?.should be_true
  end
end

shared_examples "a fixity check preservation event" do
  it_should_behave_like "a valid object preservation event"
  it "should behave like a fixity check" do
    subject.fixity_check?.should be_true
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

