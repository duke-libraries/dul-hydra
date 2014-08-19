require 'spec_helper'

module DulHydra::Batch::Models

  describe Batch, batch: true do
    
    context "destroy" do
    
      let(:batch) { FactoryGirl.create(:batch_with_basic_ingest_batch_objects) }
      before do
        batch.user.destroy
        batch.destroy
      end
      it "should destroy all the associated dependent objects" do
        DulHydra::Batch::Models::Batch.all.should be_empty
        DulHydra::Batch::Models::BatchObject.all.should be_empty
        DulHydra::Batch::Models::BatchObjectDatastream.all.should be_empty
        DulHydra::Batch::Models::BatchObjectRelationship.all.should be_empty
      end
      
    end
    
    context "validate" do
      
      let(:batch) { FactoryGirl.create(:batch_with_basic_ingest_batch_objects) }
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
        batch.should_receive(:add_found_pid).once.with(parent.pid, "TestParent").and_call_original
        batch.validate
        expect(batch.found_pids).to eq(pid_cache)
      end
      
    end

  end

end
