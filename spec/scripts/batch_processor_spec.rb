require 'spec_helper'

module DulHydra::Scripts
  
  shared_examples "a successful ingest batch" do
    let(:batch_run) { batch.batch_runs.last }
    before do
      @repo_objects = []
      batch.batch_objects.each { |obj| @repo_objects << ActiveFedora::Base.find(obj.pid, :cast => true) }
    end
    it "should add the objects to the repository, validate them, and have an appropriate batch run record" do
      expect(@repo_objects.size).to eq(batch.batch_objects.size)
      @repo_objects.each_with_index do |obj, index|
        batch_obj = batch.batch_objects[index]
        expect(obj).to be_an_instance_of(batch_obj.model.constantize)
        expect(obj.label).to eq(batch_obj.label) if batch_obj.label
#        expect(obj.admin_policy).to eq(AdminPolicy.find(batch_obj.admin_policy)) if batch_obj.admin_policy
#        expect(obj.parent).to eq(ActiveFedora::Base.find(batch_obj.parent, :cast => true)) if batch_obj.parent
#        expect(obj.collection).to eq(Collection.find(batch_obj.target_for)) if batch_obj.target_for
        batch_obj_ds = batch_obj.batch_object_datastreams
        batch_obj_ds.each { |ds| expect(obj.datastreams[ds.name].content).to_not be_nil }
        expect(obj.preservation_events.size).to eq(2)
        obj.preservation_events.each do |pe|
          expect([PreservationEvent::INGESTION, PreservationEvent::VALIDATION]).to include(pe.event_type)
          expect(pe.event_outcome).to eq(PreservationEvent::SUCCESS)
          expect(pe.linking_object_id_type).to eq(PreservationEvent::OBJECT)
          expect(pe.linking_object_id_value).to eq(obj.internal_uri)
          expect(DateTime.strptime(pe.event_date_time, PreservationEvent::DATE_TIME_FORMAT)).to be_within(3.minutes).of(DateTime.now)
          case pe.event_type
          when PreservationEvent::INGESTION
            expect(pe.event_detail).to include("Identifier: #{batch_obj.identifier}")
          when PreservationEvent::VALIDATION
            expect(pe.event_detail).to include(DulHydra::Scripts::BatchProcessor::PASS)
            expect(pe.event_detail).to_not include(DulHydra::Scripts::BatchProcessor::FAIL)
          end
        end
      end
      expect(batch_run.outcome).to eq(BatchRun::OUTCOME_SUCCESS)
      expect(batch_run.total).to eq(batch.batch_objects.size)
      expect(batch_run.success).to eq(batch_run.total)
      expect(batch_run.failure).to eq(0)
      expect(batch_run.status).to eq(BatchRun::STATUS_FINISHED)
      expect(batch_run.start).to be < batch_run.stop
      expect(batch_run.stop).to be_within(3.minutes).of(Time.now)
      expect(batch_run.version).to eq(DulHydra::VERSION)
      batch.batch_objects.each { |obj| expect(batch_run.details).to include("Ingested #{obj.model} #{obj.identifier} into #{obj.pid}") }
    end
  end
  
  describe BatchProcessor do
    let(:test_dir) { Dir.mktmpdir("dul_hydra_test") }
    let(:log_dir) { test_dir }
    after { FileUtils.remove_dir test_dir }
    context "ingest" do
      let(:batch) { FactoryGirl.create(:batch_with_ingest_batch_objects) }
      let(:bp) { DulHydra::Scripts::BatchProcessor.new(:batch_id => batch.id, :log_dir => log_dir) }
      before { bp.execute }
      after do
        batch.batch_objects.each do |obj|
          repo_obj = ActiveFedora::Base.find(obj.pid, :cast => true)
          repo_obj.parent.destroy if repo_obj.parent
          repo_obj.admin_policy.destroy if repo_obj.admin_policy
          repo_obj.destroy
        end
      end
      context "valid batch" do
        it_behaves_like "a successful ingest batch"
      end
      context "valid ingest" do
        
      end
    end
  end  
  
end

