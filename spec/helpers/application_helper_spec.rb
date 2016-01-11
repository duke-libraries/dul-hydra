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
      let(:collection1) { Collection.new(pid: 'test:1', title: [ 'Collection 1' ]) }
      let(:collection2) { Collection.new(pid: 'test:2', title: [ 'Collection 2' ]) }
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

  describe "#original_filename_info_value" do
    let(:object) { TestContent.new(pid: 'test:1') }
    before { allow(helper).to receive(:current_object) { object } }
    context "object has content" do
      before { object.upload File.new(File.join(Rails.root, "spec", "fixtures", "imageA.tif")) }
      context "object has original filename" do
        it "should return the original file name" do
          expect(helper.original_filename_info).to include(value: 'imageA.tif', context: 'info')
        end
      end
      context "object does not have original filename" do
        before { object.update_attributes(original_filename: nil) }
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

  describe "#link_to_object" do
    let(:pid) { 'test:1' }
    let(:solr_doc) { SolrDocument.new('id' => pid, Ddr::Index::Fields::ACTIVE_FEDORA_MODEL => 'Item') }
    before { allow(SolrDocument).to receive(:find).with(pid) { solr_doc } }
    context "can access" do
      before { allow(helper).to receive(:can?) { true } }
      it "should return the correct link to the object" do
        expect(helper.link_to_object(pid)).to include(item_path('test:1'))
      end
    end
    context "cannot access" do
      before { allow(helper).to receive(:can?) { false } }
      it "should return the pid without a link" do
        expect(helper.link_to_object(pid)).to eq(pid)
      end
    end
  end

end
