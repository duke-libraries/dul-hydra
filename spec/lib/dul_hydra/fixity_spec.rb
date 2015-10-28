require "spec_helper"

module DulHydra
  RSpec.describe Fixity do

    let(:obj) { FactoryGirl.create(:item) }

    describe "with an object that was just checked" do
      before do
        Ddr::Events::FixityCheckEvent.create(pid: obj.id, event_date_time: Time.now.utc)
      end
      it "should not queue the pid for fixity checking" do
        expect(Resque).not_to receive(:enqueue).with(DulHydra::Jobs::FixityCheck, obj.id)
        described_class.check
      end
    end

    describe "with an object that has not previously been checked" do
      it "should queue the pid for fixity checking" do
        expect(Resque).to receive(:enqueue).with(DulHydra::Jobs::FixityCheck, obj.id)
        described_class.check
      end
    end

    describe "with an object that was last checked one year ago" do
      before do
        Ddr::Events::FixityCheckEvent.create(pid: obj.id, event_date_time: Time.now.ago(1.year).utc)
      end
      it "should queue the pid for fixity checking" do
        expect(Resque).to receive(:enqueue).with(DulHydra::Jobs::FixityCheck, obj.id)
        described_class.check
      end
    end

  end
end
