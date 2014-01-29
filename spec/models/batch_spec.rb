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
    
    context "details size" do
      let(:batch) { FactoryGirl.create(:batch) }
      let(:details) { "a" * (2**17) }
      before do
        batch.details = details
        batch.save
      end
      after do
        batch.user.destroy
        batch.destroy
      end
      it "should properly save the details" do
        expect(DulHydra::Batch::Models::Batch.find(batch.id).details).to eq(details)
      end
    end
  end

end