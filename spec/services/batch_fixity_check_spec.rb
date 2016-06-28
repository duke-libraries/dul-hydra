require "spec_helper"

RSpec.describe BatchFixityCheck, fixity: true do
  let(:obj) { FactoryGirl.create(:item) }

  describe "with an object that was just checked" do
    before do
      Ddr::Events::FixityCheckEvent.create(pid: obj.id, event_date_time: Time.now.utc)
    end
    it "does not enqueue the object id for fixity checking" do
      expect(Resque).not_to receive(:enqueue).with(FixityCheckJob, obj.id)
      described_class.call
    end
  end

  describe "with an object that has not previously been checked" do
    it "enqueues the object id for fixity checking" do
      expect(Resque).to receive(:enqueue).with(FixityCheckJob, obj.id)
      described_class.call
    end
  end

  describe "with an object that was last checked one year ago" do
    before do
      Ddr::Events::FixityCheckEvent.create(pid: obj.id, event_date_time: Time.now.ago(1.year).utc)
    end
    it "enqueues the object id for fixity checking" do
      expect(Resque).to receive(:enqueue).with(FixityCheckJob, obj.id)
      described_class.call
    end
  end
end
