require 'spec_helper'

RSpec.describe ApplicationHelper, type: :helper do

  describe "#render_content_type_and_size" do
    before do
      allow(doc_or_obj).to receive(:content_type) { "application/pdf" }
      allow(doc_or_obj).to receive(:content_size_human) { "5K" }
    end
    context "with a document" do
      let(:doc_or_obj) { SolrDocument.new({}) }
      it "should render the content type and size" do
        expect(helper.render_content_type_and_size(doc_or_obj)).to eq("application/pdf 5K")
      end
    end
    context "with an object" do
      let(:doc_or_obj) { Component.new }
      it "should render the content type and size" do
        expect(helper.render_content_type_and_size(doc_or_obj)).to eq("application/pdf 5K")
      end
    end
  end

  describe "#model_options_for_select" do
    context "access option" do
      let(:collection1) { Collection.new(pid: 'test-1', dc_title: [ 'Collection 1' ]) }
      let(:collection2) { Collection.new(pid: 'test-2', dc_title: [ 'Collection 2' ]) }
      before do
        allow(helper).to receive(:can?).with(:edit, collection1) { true }
        allow(helper).to receive(:can?).with(:edit, collection2) { false }
        allow(helper).to receive(:find_models_with_gated_discovery) { [ collection1, collection2 ] }
      end
      it "should return the model objects to which user has appropriate access" do
        expect(helper.model_options_for_select(Collection, access: :edit)).to match(/Collection 1/)
        expect(helper.model_options_for_select(Collection, access: :edit)).to_not match(/Collection 2/)
      end
    end
  end

  describe "#original_filename_info" do
    let(:object) { TestContent.new }
    before { allow(helper).to receive(:current_object) { object } }
    context "object has content" do
      before { object.upload! File.new(File.join(Rails.root, "spec", "fixtures", "imageA.tif")) }
      context "object has original filename" do
        it "should return the original file name" do
          expect(helper.original_filename_info).to include(value: 'imageA.tif', context: 'info')
        end
      end
      context "object does not have original filename" do
        before { allow(object).to receive(:original_filename) { nil } }
        it "should return an appropriate message" do
          expect(helper.original_filename_info).to include(value: 'Missing', context: 'danger')
        end
      end
    end
    context "object does not have content" do
      it "should return an appropriate message" do
        expect(helper.original_filename_info).to include(value: 'No content file', context: 'warning')
      end
    end
  end
end
