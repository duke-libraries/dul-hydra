require 'spec_helper'
require 'fileutils'

module DulHydra::BatchIngest
  
  describe BatchIngest do
    
    context "valid ingest" do
      let(:admin_policy_object) { FactoryGirl.create(:public_read_policy) }
      let(:ingest_object) { FactoryGirl.build(:test_model_ingest_object) }
      let(:batch_ingest) { BatchIngest.new }
      let(:xls_file) { File.open("/tmp/metadata.xls") { |f| f.read } }
      before do
        ingest_object.admin_policy = admin_policy_object.pid
        @repo_object = batch_ingest.ingest(ingest_object)
      end
      after do
        @repo_object.destroy
        admin_policy_object.destroy
      end
      it "should return the repository object" do
        expect(@repo_object).to_not be_nil
        expect(@repo_object.label).to eq("Test Model Label")
        expect(@repo_object.admin_policy).to eq(admin_policy_object)
        expect(@repo_object.descMetadata.content).to be_equivalent_to("<dc xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"><dcterms:title>Test Object Title</dcterms:title></dc>")
        FileUtils.compare_stream(StringIO.new(@repo_object.digitizationGuide.content), StringIO.new(xls_file)).should be_true
      end
    end
  end
  
end
