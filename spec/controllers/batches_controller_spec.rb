require 'spec_helper'

describe BatchesController, batch: true do

  describe "#procezz" do
    let(:batch) { FactoryGirl.create(:batch_with_basic_ingest_batch_objects) }
    before do
      sign_in batch.user
      get :procezz, :id => batch.id
      batch.reload
    end
    after do
      batch.user.delete
      batch.destroy
    end
    it "should set the status of the batch to QUEUED" do
      expect(batch.status).to eq(DulHydra::Batch::Models::Batch::STATUS_QUEUED)
    end
  end


end
