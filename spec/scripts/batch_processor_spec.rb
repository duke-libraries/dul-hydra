require 'spec_helper'

module DulHydra::Batch::Scripts
  
  shared_examples "a successful ingest batch" do
    let(:log_contents) { File.read(batch.logfile.path) }
    before do
      batch.reload
      @repo_objects = []
      batch.batch_objects.each { |obj| @repo_objects << ActiveFedora::Base.find(obj.pid, :cast => true) }
    end
    it "should add the objects to the repository and verify them" do
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
      batch.batch_objects.each { |obj| expect(log_contents).to include("Ingested #{obj.model} #{obj.identifier} into #{obj.pid}") }
      expect(log_contents).to include("Ingested #{batch.success} TestModelOmnibus")
    end
  end
  
  shared_examples "a successful update batch" do
    let(:log_contents) { File.read(batch.logfile.path) }
    before do
      batch.reload
      @repo_objects = []
      batch.batch_objects.each { |obj| @repo_objects << ActiveFedora::Base.find(obj.pid, :cast => true) }
    end
    it "should update the objects in the repository" do
      expect(@repo_objects.size).to eq(batch.batch_objects.size)
      @repo_objects.each_with_index do |obj, index|
        batch_obj = batch.batch_objects[index]
        expect(obj).to be_an_instance_of(batch_obj.model.constantize)
        expect(obj.label).to eq(batch_obj.label) if batch_obj.label
        expect(obj.title.first).to eq('Sample updated title')
        batch_obj_ds = batch_obj.batch_object_datastreams
        batch_obj_ds.each { |d| expect(obj.datastreams[d.name].content).to_not be_nil }
        batch_obj_rs = batch_obj.batch_object_relationships
        batch_obj_rs.each { |r| expect(obj.send(r.name).pid).to eq(r.object) }
      end
      expect(batch.outcome).to eq(DulHydra::Batch::Models::Batch::OUTCOME_SUCCESS)
      expect(batch.success).to eq(batch.batch_objects.size)
      expect(batch.failure).to eq(0)
      expect(batch.status).to eq(DulHydra::Batch::Models::Batch::STATUS_FINISHED)
      expect(batch.start).to be <= batch.stop
      expect(batch.stop).to be_within(3.minutes).of(Time.now)
      expect(batch.version).to eq(DulHydra::VERSION)
      batch.batch_objects.each { |obj| expect(log_contents).to include("Updated #{obj.pid}") }
      expect(log_contents).to include("Updated #{batch.success} TestModelOmnibus")
    end
  end

  shared_examples "an interrupted batch run" do
    before { batch.reload }
    it "should have an interrupted status and a failed outcome" do
      expect([DulHydra::Batch::Models::Batch::STATUS_INTERRUPTED, DulHydra::Batch::Models::Batch::STATUS_RESTARTABLE]).to include(batch.status)
      expect(batch.outcome).to eq(DulHydra::Batch::Models::Batch::OUTCOME_FAILURE)
    end
    it "should have a logfile" do
      expect(batch.logfile).to_not be_nil
    end
  end
  
  describe BatchProcessor do
    let(:test_dir) { Dir.mktmpdir("dul_hydra_test") }
    let(:log_dir) { test_dir }
    after { FileUtils.remove_dir test_dir }
    context "ingest" do
      let(:batch) { FactoryGirl.create(:batch_with_generic_ingest_batch_objects) }
      let(:bp) { DulHydra::Batch::Scripts::BatchProcessor.new(:batch_id => batch.id, :log_dir => log_dir) }
      after do
        batch.batch_objects.each do |obj|
          obj.batch_object_relationships.each do |r|
            ActiveFedora::Base.find(r[:object], :cast => true).destroy if r[:name].eql?("parent")
            AdminPolicy.find(r[:object]).destroy if r[:name].eql?("admin_policy")
            Collection.find(r[:object]).destroy if r[:name].eql?("collection")
          end
          ActiveFedora::Base.find(obj.pid, :cast => true).destroy if obj.pid.present?
        end
        batch.user.destroy
        batch.destroy
      end
      context "successful initial run" do
        before { bp.execute }
        it_behaves_like "a successful ingest batch"
      end
      context "successful restart run" do
        before do
          batch.batch_objects.first.process
          batch.update_attributes(:status => DulHydra::Batch::Models::Batch::STATUS_RESTARTABLE)
          bp.execute
        end
        it_behaves_like "a successful ingest batch"        
      end
      context "exception during run" do
        before do
          DulHydra::Batch::Models::IngestBatchObject.any_instance.stub(:populate_datastream).and_raise(RuntimeError)
          bp.execute
        end
        it_behaves_like "an interrupted batch run"
      end
    end
    context "update" do
      let(:batch) { FactoryGirl.create(:batch_with_basic_update_batch_object) }
      let(:repo_object) { TestModelOmnibus.create(:pid => batch.batch_objects.first.pid, :label => 'Object Label') }
      let(:bp) { DulHydra::Batch::Scripts::BatchProcessor.new(:batch_id => batch.id, :log_dir => log_dir) }
      before do
        repo_object.edit_users = [ batch.user.user_key ]
        repo_object.save
      end
      after do
        repo_object.destroy
        batch.user.destroy
        batch.destroy
      end
      context "successful update" do
        before { bp.execute }
        it_behaves_like "a successful update batch"
      end
      context "exception during run" do
        before do
          DulHydra::Batch::Models::BatchObject.any_instance.stub(:populate_datastream).and_raise(RuntimeError)
          bp.execute
        end
        it_behaves_like "an interrupted batch run"
      end
    end
  end  
  
end

