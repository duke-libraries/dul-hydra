require 'spec_helper'

RSpec.describe Filesystem, type: :model, batch: true, standard_ingest: true do

  let(:filesystem) { Filesystem.new }

  describe '.path_to_node' do
    before { filesystem.tree = sample_filesystem_without_dot_files }
    context "full path" do
      it "should provide the full path" do
        expect(described_class.path_to_node(filesystem['movie.mp4'])).to eq('/test/directory/movie.mp4')
        expect(described_class.path_to_node(filesystem['itemA']['file01.pdf'])).to eq('/test/directory/itemA/file01.pdf')
      end
    end
    context "relative path" do
      it "should provide the relative path" do
        expect(described_class.path_to_node(filesystem['movie.mp4'], 'relative')).to eq('movie.mp4')
        expect(described_class.path_to_node(filesystem['itemA']['file01.pdf'], 'relative')).to eq('itemA/file01.pdf')
      end
    end
  end

  describe '.node_locator' do
    before { filesystem.tree = sample_filesystem_without_dot_files }
    context "root node" do
      it "include no nodes in the locator" do
        expect(described_class.node_locator(filesystem.root)).to be_nil
      end
    end
    context "first level nodes" do
      it "should include node in locator" do
        expect(described_class.node_locator(filesystem['itemA'])).to eq('itemA')
      end
    end
    context "second level nodes" do
      it "should include both nodes in locator" do
        expect(described_class.node_locator(filesystem['itemA']['file01.pdf'])).to eq('itemA/file01.pdf')
      end
    end
  end

  describe '#method_missing' do
    context 'method missing' do
      it 'should send the method to the inner tree' do
        expect(filesystem.tree).to receive(:each_leaf)
        filesystem.each_leaf
      end
    end
    context 'method not missing' do
      it 'should not send the method to the inner tree' do
        expect(filesystem.tree).to_not receive(:file_count)
        filesystem.file_count
      end
    end
  end

end
