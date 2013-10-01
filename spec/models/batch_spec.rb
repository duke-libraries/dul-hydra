require 'spec_helper'

module DulHydra::Batch::Models

  describe Batch do
    
    context "destroy" do
    
      let(:batch) { FactoryGirl.create(:batch_with_ingest_batch_objects) }
      before do
        # In the context of this test, before we destroy the batch, we delete the
        # related repository objects created by the factory that created the batch.
        # AdminPolicy.all.each { |obj| obj.destroy }
        # TestParent.all.each { |obj| obj.destroy }
        batch.destroy
      end
      after do
        # The following clean-up steps are needed only to cover the case that the test fails;
        # i.e., that batch.destroy does not successfully destroy itself and all related batch objects
        DulHydra::Batch::Models::BatchRun.all.each { |obj| obj.destroy }
        DulHydra::Batch::Models::BatchObjectRelationship.all.each { |obj| obj.destroy }
        DulHydra::Batch::Models::BatchObjectDatastream.all.each { |obj| obj.destroy }
        DulHydra::Batch::Models::BatchObject.all.each { |obj| obj.destroy }
        DulHydra::Batch::Models::Batch.all.each { |obj| obj.destroy }
      end
      it "should destroy all the associated dependent objects" do
        DulHydra::Batch::Models::Batch.all.should be_empty
        DulHydra::Batch::Models::BatchRun.all.should be_empty
        DulHydra::Batch::Models::BatchObject.all.should be_empty
        DulHydra::Batch::Models::BatchObjectDatastream.all.should be_empty
        DulHydra::Batch::Models::BatchObjectRelationship.all.should be_empty
      end
      
    end
    
  end

end