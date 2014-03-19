require "spec_helper"

describe BatchFixityCheckMailer, fixity_check: true do
  let(:bfc) { DulHydra::Scripts::BatchFixityCheck.new(:limit => 1, :dryrun => true) }
  let(:mailto) { "nowhere@example.com" }
  before do
    bfc.execute 
    @email = BatchFixityCheckMailer.send_notification(bfc, mailto).deliver!
  end
  it "should send a notification" do
    expect(ActionMailer::Base.deliveries).not_to be_empty
    expect(@email.subject).to eq("Batch Fixity Check Results")
    expect(@email.to).to eq([mailto])
  end
end
