require 'spec_helper'

module DulHydra::BatchIngest

  describe IngestObject do
    
    context "valid object" do
      let(:object) { FactoryGirl.build(:test_model_ingest_object) }
      it "should be valid" do
        expect(object.valid?).to be_true
      end
    end
    
    context "invalid object" do
      context "invalid model" do
        let(:object) { FactoryGirl.build(:bad_model_ingest_object) }
        it "should not be valid" do
          expect(object.valid?).to be_false
        end
      end
    end
      
  end

end