require 'spec_helper'

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

shared_examples "a fixity check preservation event" do
  its(:for_object) { should be_kind_of(DulHydra::Models::HasPreservationEvents) }
  its(:fixity_check?) { should be_true }
  its(:event_date_time) { should_not be_nil }
  its(:event_type) { should eq(PreservationEvent::FIXITY_CHECK) }
  its(:event_id_type) { should eq(PreservationEvent::UUID) }
  its(:event_id_value) { should_not be_nil }
  its(:linking_object_id_type) { should eq(PreservationEvent::DATASTREAM) }
end

shared_examples "an ingestion preservation event" do
  its(:for_object) { should be_kind_of(DulHydra::Models::HasPreservationEvents) }
  its(:event_date_time) { should_not be_nil }
  its(:event_type) { should eq(PreservationEvent::INGESTION) }
  its(:event_id_type) { should eq(PreservationEvent::UUID) }
  its(:event_id_value) { should_not be_nil }
  its(:linking_object_id_type) { should eq(PreservationEvent::OBJECT) }
end

shared_examples "a validation preservation event" do
  its(:for_object) { should be_kind_of(DulHydra::Models::HasPreservationEvents) }
  its(:event_date_time) { should_not be_nil }
  its(:event_type) { should eq(PreservationEvent::VALIDATION) }
  its(:event_id_type) { should eq(PreservationEvent::UUID) }
  its(:event_id_value) { should_not be_nil }
  its(:linking_object_id_type) { should eq(PreservationEvent::OBJECT) }
end

shared_examples "a fixity check success preservation event" do
  it_should_behave_like "a fixity check preservation event"
  it_should_behave_like "a preservation event having a success outcome"
end

shared_examples "a fixity check failure preservation event" do
  it_should_behave_like "a fixity check preservation event"
  it_should_behave_like "a preservation event having a failure outcome"
end

shared_examples "an ingestion success preservation event" do
  it_should_behave_like "a validation preservation event"
  it_should_behave_like "a preservation event having a success outcome"
end

shared_examples "a validation success preservation event" do
  it_should_behave_like "a validation preservation event"
  it_should_behave_like "a preservation event having a success outcome"
end

shared_examples "a validation failure preservation event" do
  it_should_behave_like "a validation preservation event"
  it_should_behave_like "a preservation event having a failure outcome"
end
