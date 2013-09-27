require 'spec_helper'

module DulHydra::Batch::Models

  describe Batch do
    
    context "destroy" do
    
      let(:batch) { FactoryGirl.create(:batch_with_generic_ingest_batch_objects) }
      before { batch.destroy }
      after do
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