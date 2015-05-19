require "spec_helper"

shared_examples "a completed batch fixity check" do
  it "should send a notification" do
    expect(ActionMailer::Base.deliveries).not_to be_empty
    expect(@email.to).to eq([mailto])
  end
end

describe BatchFixityCheckMailer, type: :mailer, fixity_check: true do

  let(:mailto) { "nowhere@example.com" }

  context "no report specified" do
    let(:bfc) { DulHydra::Scripts::BatchFixityCheck.new(limit: 1) }
    before do
      bfc.execute
      @email = BatchFixityCheckMailer.send_notification(bfc, mailto).deliver!
    end
    it_behaves_like "a completed batch fixity check"
    it "should not have an attachment" do
      expect(@email.attachments).to be_empty
    end
  end

  context "report specified" do
    let(:report_filename) { Dir::Tmpname.create(['r', '.csv']) { } }
    let(:bfc) { DulHydra::Scripts::BatchFixityCheck.new(limit: 1, report: report_filename) }
    after do
      File.unlink(report_filename) if File.exist?(report_filename)
    end
    context "no objects in report" do
      before do
        allow_any_instance_of(DulHydra::Scripts::BatchFixityCheck).to receive(:total).and_return(0)
        bfc.execute
        @email = BatchFixityCheckMailer.send_notification(bfc, mailto).deliver!
      end
      it_behaves_like "a completed batch fixity check"
      it "should not have an attachment" do
        expect(@email.attachments).to be_empty
      end
    end
    context "objects in report" do
      before do
        allow_any_instance_of(DulHydra::Scripts::BatchFixityCheck).to receive(:total).and_return(1)
        bfc.execute
        @email = BatchFixityCheckMailer.send_notification(bfc, mailto).deliver!
      end
      it_behaves_like "a completed batch fixity check"
      it "should have an attachment" do
        expect(@email.attachments).to_not be_empty
      end
    end
  end

  context "outcomes" do
    let(:report_filename) { Dir::Tmpname.create(['r', '.csv']) { } }
    let(:bfc) { DulHydra::Scripts::BatchFixityCheck.new(limit: 1, report: report_filename) }
    before do
      allow_any_instance_of(DulHydra::Scripts::BatchFixityCheck).to receive(:outcome_counts) { outcome_counts }
      bfc.execute
      @email = BatchFixityCheckMailer.send_notification(bfc, mailto).deliver!
    end
    after do
      File.unlink(report_filename) if File.exist?(report_filename)
    end
    context "when there are no failures" do
      let(:outcome_counts) { {Ddr::Events::Event::SUCCESS => 1} }
      it "should have a 'success' subject'" do
        expect(@email.subject).to eq("DDR Fixity Results: SUCCESS")
      end
    end
    context "when there are one or more failures" do
      let(:outcome_counts) { {Ddr::Events::Event::FAILURE => 1} }
      it "should have a 'failure' subject'" do
        expect(@email.subject).to eq("DDR Fixity Results: FAILURE")
      end
    end
  end
end
