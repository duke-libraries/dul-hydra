require "spec_helper"

RSpec.describe BatchFixityCheck do

  let(:obj) { FactoryGirl.create(:item) }

  describe "with an object that was just checked" do
    before do
      Ddr::Events::FixityCheckEvent.create(pid: obj.pid, event_date_time: Time.now.utc)
    end
    it "should not queue the pid for fixity checking" do
      expect(Resque).not_to receive(:enqueue).with(FixityCheckJob, obj.pid)
      described_class.call
    end
  end

  describe "with an object that has not previously been checked" do
    it "should queue the pid for fixity checking" do
      expect(Resque).to receive(:enqueue).with(FixityCheckJob, obj.pid)
      described_class.call
    end
  end

  describe "with an object that was last checked one year ago" do
    before do
      Ddr::Events::FixityCheckEvent.create(pid: obj.pid, event_date_time: Time.now.ago(1.year).utc)
    end
    it "should queue the pid for fixity checking" do
      expect(Resque).to receive(:enqueue).with(FixityCheckJob, obj.pid)
      described_class.call
    end
  end

  describe "with more objects than the limit that were last checked one year ago" do
    let(:obj2) { FactoryGirl.create(:item) }
    before do
      Ddr::Events::FixityCheckEvent.create(pid: obj.pid, event_date_time: Time.now.ago(1.year).utc)
      Ddr::Events::FixityCheckEvent.create(pid: obj2.pid, event_date_time: Time.now.ago(1.year).utc)
    end
    it "should not queue the excess pid's for fixity checking" do
      expect(Resque).to receive(:enqueue).with(FixityCheckJob, instance_of(String)).once
      described_class.call(limit: 1)
    end
  end

end
