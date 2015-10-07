require 'spec_helper'

RSpec.describe METSFileDisplayFormat, type: :model, batch: true, mets_file: true do

  let(:collection) { Collection.new }
  let(:mets_filepath) { '/tmp/mets.xml' }
  let(:mets_file) { METSFile.new(mets_filepath, collection) }
  let(:display_formats) { { 'slideshow' => 'multi_image' } }

  before { allow(File).to receive(:read).with(mets_filepath) { sample_mets_xml } }

  context "no type attribute" do
    before { allow(mets_file).to receive(:root_type_attr) { nil } }
    it "should provide nothing" do
      expect(METSFileDisplayFormat.get(mets_file, display_formats)).to be_nil
    end
  end

  context "translated type attribute" do
    before { allow(mets_file).to receive(:root_type_attr) { 'Resource:slideshow' } }
    it "should provide the translated display format" do
      expect(METSFileDisplayFormat.get(mets_file, display_formats)).to eq('multi_image')
    end
  end

  context "non-translated type attribute" do
    context "non-resource type attribute" do
      before { allow(mets_file).to receive(:root_type_attr) { 'Collection' } }
      it "should provide the downcased type attribute" do
        expect(METSFileDisplayFormat.get(mets_file, display_formats)).to eq('collection')
      end
    end
    context "resource type attribute" do
      before { allow(mets_file).to receive(:root_type_attr) { 'Resource:image' } }
      it "should provide the downcased type attribute minus the resource designation" do
        expect(METSFileDisplayFormat.get(mets_file, display_formats)).to eq('image')
      end
    end
  end

end