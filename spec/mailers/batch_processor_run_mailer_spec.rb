require "spec_helper"

describe BatchProcessorRunMailer, type: :mailer, batch: true do
  let(:batch) { FactoryGirl.create(:batch_with_basic_ingest_batch_objects) }
  let(:bp) { DulHydra::Batch::Scripts::BatchProcessor.new(batch, batch.user) }
  before { bp.execute }
  it "should send a notification" do
    expect(ActionMailer::Base.deliveries).not_to be_empty
    email = ActionMailer::Base.deliveries.first
    expect(email.to).to eq([batch.user.email])
    expect(email.subject).to include("Batch Processor Run #{batch.status}")
    expect(email.parts.first.to_s).to include("Ingested TestModelOmnibus")
    expect(email.parts.second.to_s).to include("Objects in batch: #{batch.batch_objects.count}")
    expect(email.parts.second.to_s).to include(DulHydra::Batch::Models::Batch::OUTCOME_SUCCESS)
  end
end
