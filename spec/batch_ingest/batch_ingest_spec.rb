require 'spec_helper'
require 'fileutils'

module DulHydra::BatchIngest
  
  describe BatchIngest do
    
    context "valid ingest" do
      let(:batch_ingest) { BatchIngest.new }
      context "common objects" do
        let(:admin_policy_object) { FactoryGirl.create(:public_read_policy) }
        let(:parent_object) { FactoryGirl.create(:test_parent) }
        let(:ingest_object) { FactoryGirl.build(:test_model_omnibus_ingest_object) }
        let(:xls_file) { File.open(File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'metadata.xls')) { |f| f.read } }
        let(:tif_file) { File.open(File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'id001.tif')) { |f| f.read } }
        let(:thumbnail_file) { File.open(File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'id001_thumbnail.png')) { |f| f.read } }  
        before do
          ingest_object.admin_policy = admin_policy_object.pid
          ingest_object.parent = parent_object.pid
          @repo_object = batch_ingest.ingest(ingest_object)
        end
        after do
          @repo_object.destroy
          admin_policy_object.destroy
          parent_object.destroy
        end
        it "should return the repository object" do
          expect(@repo_object).to_not be_nil
          expect(@repo_object.label).to eq("Test Model Label")
          expect(@repo_object.admin_policy).to eq(admin_policy_object)
          expect(@repo_object.descMetadata.content).to be_equivalent_to("<dc xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"><dcterms:title>Test Object Title</dcterms:title></dc>")
          FileUtils.compare_stream(StringIO.new(@repo_object.digitizationGuide.content), StringIO.new(xls_file)).should be_true
          FileUtils.compare_stream(StringIO.new(@repo_object.content.content), StringIO.new(tif_file)).should be_true
          expect(@repo_object.thumbnail.content).to_not be_nil
          expect(@repo_object.thumbnail.mimeType).to eq("image/png")
          expect(@repo_object.parent).to eq(parent_object)
        end
      end
      context "target object" do
        let(:collection_object) { FactoryGirl.create(:collection) }
        let(:ingest_object) { FactoryGirl.build(:target_ingest_object) }
        before do
          ingest_object.collection = collection_object.pid
          @repo_object = batch_ingest.ingest(ingest_object)
        end
        after do
          @repo_object.destroy
          collection_object.destroy
        end
        it "should return the repository object" do
          expect(@repo_object).to_not be_nil
          expect(@repo_object.collection).to eq(collection_object)
        end  
      end
    end
  end
  
end
