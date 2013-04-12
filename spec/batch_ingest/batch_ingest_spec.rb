require 'spec_helper'

module DulHydra::BatchIngest
  
  describe BatchIngest do
    
    context "valid ingest" do
      let(:ingest_object) { FactoryGirl.build(:collection_ingest_object) }
      let(:batch_ingest) { BatchIngest.new }
      before do
        @repo_object = batch_ingest.ingest(ingest_object)
      end
      after do
        @repo_object.destroy
      end
      it "should return the repository object" do
        expect(@repo_object).to_not be_nil
      end
    end
    
  end
  
end
