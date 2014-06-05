require "spec_helper"

shared_examples "a completed batch fixity check" do
  it "should send a notification" do
    expect(ActionMailer::Base.deliveries).not_to be_empty
    expect(@email.subject).to eq("Batch Fixity Check Results")
    expect(@email.to).to eq([mailto])
  end  
end

describe BatchFixityCheckMailer, fixity_check: true do
  
  let(:mailto) { "nowhere@example.com" }

  context "no report specified" do
    let(:bfc) { DulHydra::Scripts::BatchFixityCheck.new(:limit => 1, :dryrun => true) }
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
    let(:bfc) { DulHydra::Scripts::BatchFixityCheck.new(:limit => 1, :dryrun => true, :report => report_filename) }
    context "no objects in report" do
      before do
        DulHydra::Scripts::BatchFixityCheck.any_instance.stub(:total).and_return(0)
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
        DulHydra::Scripts::BatchFixityCheck.any_instance.stub(:total).and_return(1)
        bfc.execute 
        @email = BatchFixityCheckMailer.send_notification(bfc, mailto).deliver!
      end
      it_behaves_like "a completed batch fixity check"
      it "should have an attachment" do
        expect(@email.attachments).to_not be_empty
      end      
    end
  end
end
