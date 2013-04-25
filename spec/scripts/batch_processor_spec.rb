require 'spec_helper'

module DulHydra::Scripts
  
  shared_examples "a successful ingest batch" do
    let(:log_file_contents) { File.read(log_file_path) }
    it "should produce an appropriate log file" do
      expect(File.exists?(log_file_path)).to be_true
      expect(log_file_contents).to include("Batch")
      expect(log_file_contents).to include("Ingested #{batch.batch_objects.size} of #{batch.batch_objects.size} objects")
    end
  end
  
  describe BatchProcessor do
    let(:test_dir) { Dir.mktmpdir("dul_hydra_test") }
    let(:batch) { FactoryGirl.create(:batch_with_ingest_batch_objects) }
    let(:log_file_path) { File.join(test_dir, "batch_process.log") }
    let(:bp) { DulHydra::Scripts::BatchProcessor.new(:batch_id => batch.id, :log_file => log_file_path) }
    before { bp.execute }
    after { FileUtils.remove_dir test_dir }
    context "ingest" do
      context "valid batch" do
        it_behaves_like "a successful ingest batch"
      end
    end
  end  
  
end

