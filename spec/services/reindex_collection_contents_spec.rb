RSpec.describe ReindexCollectionContents do

  describe "triggering" do
    describe "on collection update" do
      before {
        @collection = FactoryGirl.create(:collection)
      }
      describe "when a tracked attribute changed" do
        it "calls the service" do
          expect(described_class).to receive(:call).with(@collection.pid)
          @collection.title = [ "Title Changed" ]
          @collection.save!
        end
      end
      describe "when no tracked attribute is changed" do
        it "does not call the service" do
          expect(described_class).not_to receive(:call).with(@collection.pid)
          @collection.local_id = "001"
          @collection.save!
        end
      end
    end
  end

  describe ".call" do
    describe "error conditions" do
      specify {
        expect { described_class.call("foo:1") }.to raise_error(ActiveFedora::ObjectNotFoundError)
      }
      specify {
        expect { described_class.call(nil) }.to raise_error(TypeError)
      }
      specify {
        expect { described_class.call(Collection.new) }.to raise_error(ArgumentError)
      }
      specify {
        collection = FactoryGirl.create(:collection)
        expect { described_class.call(collection) }.not_to raise_error
        expect { described_class.call(collection.pid) }.not_to raise_error
      }
    end
    describe "non-error condition" do
      let(:collection) { FactoryGirl.create(:collection) }
      let(:items) { FactoryGirl.build_list(:item, 3) }
      let(:components) { FactoryGirl.build_list(:component, 2) }
      before {
        items.each do |item|
          item.parent = collection
          item.admin_policy = collection
          item.save!
        end
        components.each do |component|
          component.parent = items.first
          component.admin_policy = collection
          component.save!
        end
      }
      it "reindexes the contents" do
        items.each do |item|
          expect(Resque).to receive(:enqueue).with(UpdateIndexJob, item.pid)
        end
        components.each do |component|
          expect(Resque).to receive(:enqueue).with(UpdateIndexJob, component.pid)
        end
        described_class.call(collection.pid)
      end
    end
  end

end
