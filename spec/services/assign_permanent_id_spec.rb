RSpec.describe AssignPermanentId do

  let(:obj) { FactoryGirl.create(:item) }
  let(:id) { PermanentId.identifier_class.new("foo") }

  before do
    allow(obj).to receive(:reload) { nil }
    allow(obj).to receive(:save) { nil }
    allow(PermanentId.identifier_class).to receive(:mint) { id }
    allow(id).to receive(:save) { nil }
  end

  describe "triggered by create?" do
    describe "when auto assign is enabled" do
      before do
        allow(DulHydra).to receive(:auto_assign_permanent_id) { true }
      end
      specify {
        expect(described_class).to receive(:call).with("test:1") { nil }
        Item.create(pid: "test:1")
      }
    end
    describe "when auto assign is disabled" do
      before do
        allow(DulHydra).to receive(:auto_assign_permanent_id) { false }
      end
      specify {
        expect(described_class).not_to receive(:call)
        Item.create(pid: "test:1")
      }
    end
  end

  describe "when passed an object" do
    specify {
      described_class.call(obj)
      expect(obj.permanent_id).to eq("foo")
    }
  end

  describe "when passed a PID" do
    let(:object_or_id) { "test:1" }
    before {
      allow(ActiveFedora::Base).to receive(:find).with("test:1") { obj }
    }
    specify {
      described_class.call(object_or_id)
      expect(obj.permanent_id).to eq("foo")
    }
  end

  describe "when the object already has a permanent id" do
    let(:object_or_id) { obj }
    before do
      obj.permanent_id = "foo"
    end
    specify {
      expect(Rails.logger).to receive(:warn)
      expect(described_class.call(object_or_id)).to be false
    }
  end

end
