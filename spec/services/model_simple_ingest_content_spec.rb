require 'spec_helper'
require 'support/ingest_folder_helper'

shared_examples "a properly modeled filesystem node" do
  it "should determine the proper content model" do
    expect(ModelSimpleIngestContent.new(node).call).to eq(proper_model)
  end
end

RSpec.describe ModelSimpleIngestContent, type: :service, batch: true, simple_ingest: true do

  let(:root_node) { Tree::TreeNode.new('/test/directory') }
  let(:nodeA) { Tree::TreeNode.new('A') }
  let(:nodeB) { Tree::TreeNode.new('B') }
  let(:nodeC) { Tree::TreeNode.new('C') }
  let(:nodeD) { Tree::TreeNode.new('D') }
  let(:nodeE) { Tree::TreeNode.new('E') }
  let(:nodeF) { Tree::TreeNode.new('F') }

  before do
    root_node << nodeA
    root_node << nodeB << nodeC
    root_node << nodeD << nodeE << nodeF
  end
  context "root node" do
    let(:node) { root_node }
    let(:proper_model) { 'Collection' }
    it_should_behave_like "a properly modeled filesystem node"
  end
  context "childless node in root node" do
    let(:node) { nodeA }
    let(:proper_model) { 'Item' }
    it_should_behave_like "a properly modeled filesystem node"
  end
  context "childed node in root node" do
    let(:node) { nodeB }
    let(:proper_model) { 'Item' }
    it_should_behave_like "a properly modeled filesystem node"
  end
  context "childless node in childed node in root node" do
    let(:node) { nodeC }
    let(:proper_model) { 'Component' }
    it_should_behave_like "a properly modeled filesystem node"
  end
  context "childed node in childed node in root node" do
    let(:node) { nodeE }
    it "should raise a deepest node has children error" do
      expect { ModelSimpleIngestContent.new(node).call }.to raise_error(DulHydra::BatchError, /Deepest .* has children/)
    end
  end
  context "third-level node" do
    let(:node) { nodeF }
    it "should raise a node too deep exception" do
      expect { ModelSimpleIngestContent.new(node).call }.to raise_error(DulHydra::BatchError, /too deep/)
    end
  end

end