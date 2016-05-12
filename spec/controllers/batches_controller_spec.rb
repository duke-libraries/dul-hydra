require 'spec_helper'

describe BatchesController, type: :controller, batch: true do

  shared_examples "a delete-able batch" do
    it "should delete the batch and redirect to the index page" do
      delete :destroy, :id => batch
      expect{ Ddr::Batch::Batch.find(batch.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(subject).to redirect_to(batches_path)
    end
  end

  shared_examples "a non-delete-able batch" do
    it "should not delete the batch and redirect to the index page" do
      delete :destroy, :id => batch
      expect(Ddr::Batch::Batch.find(batch.id)).to eql(batch)
      expect(subject).to redirect_to(batches_path)
    end
  end

  describe "#index" do
    let(:user) { FactoryGirl.create(:user) }
    let!(:batches) { [ Ddr::Batch::Batch.create(user: user, start: DateTime.now - 7),
                       Ddr::Batch::Batch.create(user: user),
                       Ddr::Batch::Batch.create(user: user, start: DateTime.now) ] }
    before { sign_in user }
    it "should display the batches in descending order by start time, with non-started batches first" do
      get(:index)
      expect(assigns(:batches)).to eq([ batches[1], batches[2], batches[0] ])
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
    end
  end

  describe "#procezz" do
    let(:batch) { FactoryGirl.create(:batch_with_basic_ingest_batch_objects) }
    before { sign_in batch.user }
    it "should enqueue the job" do
      expect(Resque).to receive(:enqueue).with(Ddr::Batch::BatchProcessorJob, batch.id, batch.user.id)
      get :procezz, :id => batch.id
    end
    it "should redirect to the batch url" do
      allow(Resque).to receive(:enqueue).with(Ddr::Batch::BatchProcessorJob, batch.id, batch.user.id)
      get :procezz, :id => batch.id
      expect(response).to redirect_to(batch_url)
    end
  end

end
