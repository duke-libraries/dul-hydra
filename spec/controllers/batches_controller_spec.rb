require 'spec_helper'

describe BatchesController, type: :controller, batch: true do

  shared_examples "a delete-able batch" do
    it "should delete the batch and redirect to the index page" do
      expect(Resque).to receive(:enqueue).with(Ddr::Batch::BatchDeletionJob, batch.id)
      delete :destroy, :id => batch
      expect(subject).to redirect_to(batches_path)
    end
  end

  shared_examples "a non-delete-able batch" do
    it "should not delete the batch and redirect to the index page" do
      expect(Resque).not_to receive(:enqueue).with(Ddr::Batch::BatchDeletionJob, batch.id)
      delete :destroy, :id => batch
      expect(subject).to redirect_to(batches_path)
    end
  end

  describe "#destroy" do
    let(:batch) { FactoryGirl.create(:batch_with_basic_ingest_batch_objects) }
    before { sign_in batch.user }
    context "batch is pending (nil)" do
      it_behaves_like "a delete-able batch"
    end
    context "batch is validated" do
      before do
        batch.status = Ddr::Batch::Batch::STATUS_VALIDATED
        batch.save!
      end
      it_behaves_like "a delete-able batch"
    end
    context "batch is queued" do
      before do
        batch.status = Ddr::Batch::Batch::STATUS_QUEUED
        batch.save!
      end
      it_behaves_like "a non-delete-able batch"
    end
    context "batch is running" do
      before do
        batch.status = Ddr::Batch::Batch::STATUS_RUNNING
        batch.save!
      end
      it_behaves_like "a non-delete-able batch"
    end
    context "batch is finished" do
      before do
        batch.status = Ddr::Batch::Batch::STATUS_FINISHED
        batch.save!
      end
      it_behaves_like "a non-delete-able batch"
    end
    context "batch is interrupted" do
      context "batch is not restartable" do
        before do
          batch.status = Ddr::Batch::Batch::STATUS_INTERRUPTED
          batch.save!
        end
        it_behaves_like "a non-delete-able batch"
      end
      context "batch is restartable" do
        before do
          batch.status = Ddr::Batch::Batch::STATUS_RESTARTABLE
          batch.save!
        end
        it_behaves_like "a non-delete-able batch"
      end
      context "batch is queued for deletion" do
        before do
          batch.status = Ddr::Batch::Batch::STATUS_QUEUED_FOR_DELETION
          batch.save!
        end
        it_behaves_like "a non-delete-able batch"
      end
      context "batch is deleting" do
        before do
          batch.status = Ddr::Batch::Batch::STATUS_DELETING
          batch.save!
        end
        it_behaves_like "a non-delete-able batch"
      end
    end
  end

  describe "#procezz" do
    let(:batch) { FactoryGirl.create(:batch_with_basic_ingest_batch_objects) }
    before { sign_in batch.user }
    it "should enqueue the job" do
      expect(Resque).to receive(:enqueue).with(Ddr::Batch::BatchProcessorJob, batch.id, batch.user.id)
      get :procezz, :id => batch.id
    end
    it "should redirect to the batches url" do
      allow(Resque).to receive(:enqueue).with(Ddr::Batch::BatchProcessorJob, batch.id, batch.user.id)
      get :procezz, :id => batch.id
      expect(response).to redirect_to(batches_url)
    end
  end

end
