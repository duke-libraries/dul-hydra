require 'spec_helper'

module DulHydra::Batch::Models

  describe Batch do
    
    context "destroy" do
    
      let(:batch) { FactoryGirl.create(:batch_with_basic_ingest_batch_objects) }
      before do
        batch.destroy
      end
      after do
        # The following clean-up steps are needed only to cover the case that the test fails;
        # i.e., that batch.destroy does not successfully destroy itself and all related batch objects
        DulHydra::Batch::Models::BatchObjectRelationship.all.each { |obj| obj.destroy }
        DulHydra::Batch::Models::BatchObjectDatastream.all.each { |obj| obj.destroy }
        DulHydra::Batch::Models::BatchObject.all.each { |obj| obj.destroy }
        DulHydra::Batch::Models::Batch.all.each { |obj| obj.destroy }
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
      let(:admin_policy) { FactoryGirl.create(:admin_policy) }
      let(:pid_cache) { { admin_policy.pid => admin_policy.class.name} }
      
      before do
        batch.batch_objects.each do |obj|
          obj.batch_object_relationships << 
              DulHydra::Batch::Models::BatchObjectRelationship.new(
                  :name => DulHydra::Batch::Models::BatchObjectRelationship::RELATIONSHIP_ADMIN_POLICY,
                  :object => admin_policy.pid,
                  :object_type => DulHydra::Batch::Models::BatchObjectRelationship::OBJECT_TYPE_PID,
                  :operation => DulHydra::Batch::Models::BatchObjectRelationship::OPERATION_ADD
                  )
        end
      end
      
      after do
        admin_policy.delete
        batch.destroy
      end

      it "should cache the results of looking up relationship objects" do
        puts batch.id
        batch.should_receive(:add_found_pid).once.with(admin_policy.pid, "AdminPolicy").and_call_original
        batch.validate
        expect(batch.found_pids).to eq(pid_cache)
      end
      
    end

  end

end