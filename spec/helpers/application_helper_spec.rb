require 'spec_helper'

RSpec.describe ApplicationHelper, type: :helper do

  describe "#group_option_text" do
    let(:group) { Ddr::Auth::Group.new("admins", label: "Administrators") }
    it "should return the group label" do
      expect(helper.group_option_text(group)).to eq("Administrators")
    end
  end

  describe "#group_option_value" do
    let(:group) { Ddr::Auth::Group.new("admins", label: "Administrators") }
    it "should return the \"group:{group name}\"" do
      expect(helper.group_option_value(group)).to eq("group:admins")
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
end
