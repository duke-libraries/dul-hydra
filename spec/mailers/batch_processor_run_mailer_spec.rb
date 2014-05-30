require "spec_helper"

describe BatchProcessorRunMailer, batch: true do
  let(:batch) { FactoryGirl.create(:batch_with_basic_ingest_batch_objects) }
  let(:bp) { DulHydra::Batch::Scripts::BatchProcessor.new(:batch_id => batch.id) }
  before { bp.execute }
  it "should send a notification" do
    ActionMailer::Base.deliveries.should_not be_empty
    email = ActionMailer::Base.deliveries.first
    email.to.should == [batch.user.email]
    email.subject.should include("Batch Processor Run #{batch.status}")
    email.parts.first.to_s.should include("Ingested TestModelOmnibus")
    email.parts.second.to_s.should include("Objects in batch: #{batch.batch_objects.count}")
    email.parts.second.to_s.should include(DulHydra::Batch::Models::Batch::OUTCOME_SUCCESS)
  end
end
