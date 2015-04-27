require 'spec_helper'

module DulHydra::Batch::Models

  describe Batch, type: :model, batch: true do

    let(:batch) { FactoryGirl.create(:batch_with_basic_ingest_batch_objects) }

    context "completed count" do
      before { batch.batch_objects.first.update_attributes(verified: true) }
      it "should return the number of verified batch objects" do
        expect(batch.completed_count).to eq(1)
      end
    end

    context "time to complete" do
      before do
        batch.batch_objects.first.update_attributes(verified: true)
        batch.update_attributes(processing_step_start: DateTime.now - 5.minutes)
      end
      it "should estimate the time to complete processing" do
        expect(batch.time_to_complete).to be_within(3).of(600)
      end
    end

    context "destroy" do
      before do
        batch.user.destroy
        batch.destroy
      end
      it "should destroy all the associated dependent objects" do
        expect(DulHydra::Batch::Models::Batch.all).to be_empty
        expect(DulHydra::Batch::Models::BatchObject.all).to be_empty
        expect(DulHydra::Batch::Models::BatchObjectDatastream.all).to be_empty
        expect(DulHydra::Batch::Models::BatchObjectRelationship.all).to be_empty
      end
    end

    context "validate" do
      let(:parent) { FactoryGirl.create(:test_parent) }
      let(:pid_cache) { { parent.pid => parent.class.name} }
      before do
        batch.batch_objects.each do |obj|
          obj.batch_object_relationships <<
              DulHydra::Batch::Models::BatchObjectRelationship.new(
                  :name => DulHydra::Batch::Models::BatchObjectRelationship::RELATIONSHIP_PARENT,
                  :object => parent.pid,
                  :object_type => DulHydra::Batch::Models::BatchObjectRelationship::OBJECT_TYPE_PID,
                  :operation => DulHydra::Batch::Models::BatchObjectRelationship::OPERATION_ADD
                  )
        end
      end
      it "should cache the results of looking up relationship objects" do
        expect(batch).to receive(:add_found_pid).once.with(parent.pid, "TestParent").and_call_original
        batch.validate
        expect(batch.found_pids).to eq(pid_cache)
      end
    end

  end

end
