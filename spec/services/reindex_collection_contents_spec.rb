RSpec.describe ReindexCollectionContents do

  describe "triggering" do
    describe "on collection update" do
      before {
        @collection = FactoryGirl.create(:collection)
      }
      describe "when adminMetadata datastream changed" do
        it "reindexes" do
          expect(ReindexQueryResult).to receive(:call)
          @collection.admin_set = "bar"
          @collection.save!
        end
      end
      describe "when descMetadata datastream changed" do
        it "reindexes" do
          expect(ReindexQueryResult).to receive(:call)
          @collection.title = [ "Title Changed" ]
          @collection.save!
        end
      end
      describe "when RELS-EXT datastream changed" do
        it "does not reindex" do
          expect(ReindexQueryResult).not_to receive(:call)
          @collection.admin_policy = FactoryGirl.create(:collection)
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
