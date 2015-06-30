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
        obj.events.each do |event|
          expect(event).to be_success
          expect(event.pid).to eq(obj.pid)
          expect(event.event_date_time).to be_within(3.minutes).of(DateTime.now)
          case event.type
          when "Ddr::Events::FixityCheckEvent"
            expect(event.detail).to include(Ddr::Events::FixityCheckEvent::VALID)
            expect(event.detail).to_not include(Ddr::Events::FixityCheckEvent::INVALID)
          when "Ddr::Events::IngestionEvent"
            expect(event.summary).to include("Batch object identifier: #{batch_obj.identifier}")
            expect(event.user_key).to eq(bp_user.user_key)
          when "Ddr::Events::ValidationEvent"
            expect(event.detail).to include(DulHydra::Batch::Scripts::BatchProcessor::PASS)
            expect(event.detail).to_not include(DulHydra::Batch::Scripts::BatchProcessor::FAIL)
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
      batch.batch_objects.each { |obj| @repo_objects << ActiveFedora::Base.find(obj.pid) }
    end
    it "should update the objects in the repository" do
      expect(@repo_objects.size).to eq(batch.batch_objects.size)
      @repo_objects.each_with_index do |obj, index|
        batch_obj = batch.batch_objects[index]
        expect(obj).to be_an_instance_of(batch_obj.model.constantize)
        expect(obj.label).to eq(batch_obj.label) if batch_obj.label
        expect(obj.title).to eq([ 'Test Object Title' ])
        expect(obj.update_events.last.user_key).to eq(bp_user.user_key)
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

  shared_examples "an invalid batch" do
    before { batch.reload }
    it "should have an invalid status and a failed outcome" do
      expect(batch.status).to eq(DulHydra::Batch::Models::Batch::STATUS_INVALID)
      expect(batch.outcome).to eq(DulHydra::Batch::Models::Batch::OUTCOME_FAILURE)
    end
    it "should have a logfile" do
      expect(batch.logfile).to_not be_nil
    end
  end

  describe BatchProcessor do
    let(:test_dir) { Dir.mktmpdir("dul_hydra_test") }
    let(:log_dir) { test_dir }
    let(:bp_user) { FactoryGirl.create(:user) }
    before do
      allow(File).to receive(:readable?).and_call_original
      allow(File).to receive(:readable?).with("/tmp/qdc-rdf.nt").and_return(true)
      allow(File).to receive(:read).and_call_original
    end
    after { FileUtils.remove_dir test_dir }
    context "ingest" do
      let(:batch) { FactoryGirl.create(:batch_with_generic_ingest_batch_objects) }
      let(:bp) { DulHydra::Batch::Scripts::BatchProcessor.new(batch, bp_user, log_dir: log_dir) }
      context "successful initial run" do
        before { bp.execute }
        it_behaves_like "a successful ingest batch"
      end
      context "successful restart run" do
        before do
          batch.batch_objects.first.process(bp_user)
          batch.update_attributes(:status => DulHydra::Batch::Models::Batch::STATUS_RESTARTABLE)
          bp.execute
        end
        it_behaves_like "a successful ingest batch"
      end
      context "exception during run" do
        before do
          allow_any_instance_of(DulHydra::Batch::Models::IngestBatchObject).to receive(:populate_datastream).and_raise(RuntimeError)
          bp.execute
        end
        it_behaves_like "an interrupted batch run"
      end
    end
    context "update" do
      let(:batch) { FactoryGirl.create(:batch_with_basic_update_batch_object) }
      let(:repo_object) do
        r_obj = TestModelOmnibus.new(:pid => batch.batch_objects.first.pid, :label => 'Object Label')
        r_obj.add_file("#{Rails.root}/spec/fixtures/imageA.tif", Ddr::Datastreams::CONTENT)
        r_obj.save
        r_obj
      end
      let(:bp) { DulHydra::Batch::Scripts::BatchProcessor.new(batch, bp_user, log_dir: log_dir) }
      before do
        batch.user.can :edit, repo_object
      end
      context "successful update" do
        before { bp.execute }
        it_behaves_like "a successful update batch"
      end
      context "invalid batch" do
        before do
          batch.batch_objects.first.update_attributes(pid: nil)
          bp.execute
        end
        it_behaves_like "an invalid batch"
      end
      context "exception during run" do
        before do
          allow_any_instance_of(DulHydra::Batch::Models::BatchObject).to receive(:add_attribute).and_raise(RuntimeError)
          bp.execute
        end
        it_behaves_like "an interrupted batch run"
      end
    end
  end

end

