require 'spec_helper'

describe DulHydra::BatchIngest::IngestObject do
  
  context "valid object" do
    let(:object) { FactoryGirl.build(:collection_ingest_object) }
    it "should be valid" do
      expect(object.valid?).to be_true
    end
  end
end