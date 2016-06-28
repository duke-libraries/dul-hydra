RSpec.describe VersionCreation, type: :services do
  describe ".enable!" do
    specify {
      expect(ActiveSupport::Notifications).to receive(:subscribe).with(Ddr::Models::Base::SAVE_NOTIFICATION, described_class) { nil }
      described_class.enable!
    }
  end

  describe ".disable!" do
    specify {
      expect(ActiveSupport::Notifications).to receive(:unsubscribe).with(described_class) { nil }
      described_class.disable!
    }
  end

  describe ".queued?" do
    specify {
      allow(VersionCreationJob).to receive(:queued_object_ids) { [ "test-1"] }
      expect(described_class.queued?("test-1")).to be true
    }
    specify {
      allow(VersionCreationJob).to receive(:queued_object_ids) { [ "test-2"] }
      expect(described_class.queued?("test-1")).to be false
    }
  end

  describe "job queueing" do
    let(:obj) { Item.new(id: "test-1") }
    after { obj.delete(eradicate: true) }

    describe "when it is subscribed to the object after_save notification" do
      around(:example) do |example|
        callback = proc { |*args| described_class.call(*args) }
        ActiveSupport::Notifications.subscribed(callback, Ddr::Models::Base::SAVE_NOTIFICATION) do
          example.run
        end
      end

      describe "and object id is not enqueued" do
        before {
          allow(described_class).to receive(:queued?).with("test-1") { false }
        }
        it "enqueues a job" do
          expect(described_class).to receive(:enqueue).with("test-1")
          obj.save
        end
      end

      describe "and object id enqueued" do
        before {
          allow(described_class).to receive(:queued?).with("test-1") { true }
        }
        it "does not enqueue a job" do
          expect(described_class).not_to receive(:enqueue).with("test-1")
          obj.save
        end
      end
    end

    describe "when it is not subscribed to the object after_save callback" do
      it "does not enqueue a job" do
        expect(described_class).not_to receive(:enqueue).with("test-1")
        obj.save
      end
    end
  end
end
