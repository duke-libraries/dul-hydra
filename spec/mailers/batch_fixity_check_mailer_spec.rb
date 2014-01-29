require "spec_helper"

describe BatchFixityCheckMailer, fixity_check: true do
  let(:bfc) { DulHydra::Scripts::BatchFixityCheck.new(:limit => 1, :dryrun => true) }
  let(:mailto) { "nowhere@example.com" }
  before { bfc.execute }
  it "should send a notification" do
    email = BatchFixityCheckMailer.send_notification(bfc, mailto).deliver!
    ActionMailer::Base.deliveries.should_not be_empty
    email.subject.should include("Batch Fixity Check Results")
    email.to.should == [mailto]
  end
end
