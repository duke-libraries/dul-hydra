require 'spec_helper'
require 'support/ingest_folder_helper'

shared_examples "a properly modeled nested folder ingest filesystem node" do
  it "should determine the proper content model" do
    expect(ModelNestedFolderIngestContent.new(node).call).to eq(proper_model)
  end
end

RSpec.describe ModelNestedFolderIngestContent, type: :service, batch: true, ingest: true do

  let(:root_node) { Tree::TreeNode.new('/test/directory') }
  let(:nodeA) { Tree::TreeNode.new('A') }
  let(:nodeB) { Tree::TreeNode.new('B') }
  let(:nodeC) { Tree::TreeNode.new('C') }

  before do
    root_node << nodeA
    root_node << nodeB << nodeC
  end
  context "root node" do
    let(:node) { root_node }
    let(:proper_model) { 'Collection' }
    it_should_behave_like "a properly modeled nested folder ingest filesystem node"
  end
  context "childless node in root node" do
    let(:node) { nodeA }
    let(:proper_model) { 'Component' }
    it_should_behave_like "a properly modeled nested folder ingest filesystem node"
  end
  context "childed node in root node" do
    let(:node) { nodeB }
    let(:proper_model) { nil }
    it_should_behave_like "a properly modeled nested folder ingest filesystem node"
  end
  context "childless node in childed node in root node" do
    let(:node) { nodeC }
    let(:proper_model) { 'Component' }
    it_should_behave_like "a properly modeled nested folder ingest filesystem node"
  end
end
