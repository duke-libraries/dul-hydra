require 'spec_helper'

module DulHydra::Batch::Scripts
  
  shared_examples "a successful ingest batch" do
    before do
      batch.reload
      @repo_objects = []
      batch.batch_objects.each { |obj| @repo_objects << ActiveFedora::Base.find(obj.pid, :cast => true) }
    end
    it "should add the objects to the repository, validate them, and have an appropriate batch run record" do
      expect(@repo_objects.size).to eq(batch.batch_objects.size)
      @repo_objects.each_with_index do |obj, index|
        batch_obj = batch.batch_objects[index]
        expect(obj).to be_an_instance_of(batch_obj.model.constantize)
        expect(obj.label).to eq(batch_obj.label) if batch_obj.label
        batch_obj_ds = batch_obj.batch_object_datastreams
        batch_obj_ds.each { |d| expect(obj.datastreams[d.name].content).to_not be_nil }
        batch_obj_rs = batch_obj.batch_object_relationships
        batch_obj_rs.each { |r| expect(obj.send(r.name).pid).to eq(r.object) }
        expect(obj.preservation_events.count).to eq(3)
        obj.preservation_events.each do |pe|
          expect([PreservationEvent::FIXITY_CHECK, PreservationEvent::INGESTION, PreservationEvent::VALIDATION]).to include(pe.event_type)
          expect(pe.event_outcome).to eq(PreservationEvent::SUCCESS)
          expect(pe.linking_object_id_type).to eq(PreservationEvent::OBJECT)
          expect(pe.linking_object_id_value).to eq(obj.pid)
          expect(pe.event_date_time).to be_within(3.minutes).of(DateTime.now)
          case pe.event_type
          when PreservationEvent::FIXITY_CHECK
            expect(pe.event_outcome_detail_note).to include(PreservationEvent::VALID)
            expect(pe.event_outcome_detail_note).to_not include(PreservationEvent::INVALID)
          when PreservationEvent::INGESTION
            expect(pe.event_detail).to include("Batch object identifier: #{batch_obj.identifier}")
          when PreservationEvent::VALIDATION
            expect(pe.event_outcome_detail_note).to include(DulHydra::Batch::Scripts::BatchProcessor::PASS)
            expect(pe.event_outcome_detail_note).to_not include(DulHydra::Batch::Scripts::BatchProcessor::FAIL)
          end
        end
      end
      expect(batch.outcome).to eq(DulHydra::Batch::Models::Batch::OUTCOME_SUCCESS)
      expect(batch.success).to eq(batch.batch_objects.size)
      expect(batch.failure).to eq(0)
      expect(batch.status).to eq(DulHydra::Batch::Models::Batch::STATUS_FINISHED)
      expect(batch.start).to be < batch.stop
      expect(batch.stop).to be_within(3.minutes).of(Time.now)
      expect(batch.version).to eq(DulHydra::VERSION)
      batch.batch_objects.each { |obj| expect(batch.details).to include("Ingested #{obj.model} #{obj.identifier} into #{obj.pid}") }
    end
  end
  
  describe BatchProcessor do
    let(:test_dir) { Dir.mktmpdir("dul_hydra_test") }
    let(:log_dir) { test_dir }
    after { FileUtils.remove_dir test_dir }
    context "ingest" do
      let(:batch) { FactoryGirl.create(:batch_with_generic_ingest_batch_objects) }
      let(:bp) { DulHydra::Batch::Scripts::BatchProcessor.new(:batch_id => batch.id, :log_dir => log_dir) }
      before { bp.execute }
      after do
        batch.batch_objects.each do |obj|
          repo_obj = ActiveFedora::Base.find(obj.pid, :cast => true)
          repo_obj.parent.destroy if repo_obj.parent
          repo_obj.admin_policy.destroy if repo_obj.admin_policy
          repo_obj.destroy
        end
      end
      context "successful ingest" do
        it_behaves_like "a successful ingest batch"
      end
    end
  end  
  
end

