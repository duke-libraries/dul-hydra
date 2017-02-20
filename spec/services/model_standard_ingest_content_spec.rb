require 'spec_helper'
require 'support/ingest_folder_helper'

shared_examples "a properly modeled filesystem node" do
  it "should determine the proper content model" do
    expect(ModelStandardIngestContent.new(node, targets_name).call).to eq(proper_model)
  end
end

RSpec.describe ModelStandardIngestContent, type: :service, batch: true, standard_ingest: true do

  let(:targets_name) { 'dpc_targets' }
  let(:root_node) { Tree::TreeNode.new('/test/directory') }
  let(:nodeA) { Tree::TreeNode.new('A') }
  let(:nodeB) { Tree::TreeNode.new('B') }
  let(:nodeC) { Tree::TreeNode.new('C') }
  let(:nodeD) { Tree::TreeNode.new('D') }
  let(:nodeE) { Tree::TreeNode.new('E') }
  let(:nodeF) { Tree::TreeNode.new('F') }
  let(:nodeTargets) { Tree::TreeNode.new(targets_name) }
  let(:nodeTarget) { Tree::TreeNode.new('T') }

  before do
    root_node << nodeA
    root_node << nodeB << nodeC
    root_node << nodeD << nodeE << nodeF
    root_node << nodeTargets << nodeTarget
  end
  context "root node" do
    let(:node) { root_node }
    let(:proper_model) { 'Collection' }
    it_should_behave_like "a properly modeled filesystem node"
  end
  context "non-targets" do
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
  end
  context "targets" do
    context "childed node in root node" do
      let(:node) { nodeTargets }
      let(:proper_model) { nil }
      it_should_behave_like "a properly modeled filesystem node"
    end
    context "childless node in childed node in root node" do
      let(:node) { nodeTarget }
      let(:proper_model) { 'Target' }
      it_should_behave_like "a properly modeled filesystem node"
    end
  end
  context "childed node in childed node in root node" do
    let(:node) { nodeE }
    it "should raise a deepest node has children error" do
      expect { ModelStandardIngestContent.new(node).call }.to raise_error(DulHydra::BatchError, /Deepest .* has children/)
    end
  end
  context "third-level node" do
    let(:node) { nodeF }
    it "should raise a node too deep exception" do
      expect { ModelStandardIngestContent.new(node).call }.to raise_error(DulHydra::BatchError, /too deep/)
    end
  end

end
