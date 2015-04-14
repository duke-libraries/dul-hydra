require 'spec_helper'

RSpec.describe 'application/_object_info.html.erb', type: :view do

  before(:all) do
    class ObjectInfoable < ActiveFedora::Base
      include Ddr::Models::EventLoggable
      include Ddr::Models::HasAdminMetadata
    end
    class ContentObjectInfoable < ObjectInfoable
      include Ddr::Models::HasContent
    end
  end

  before do
    allow(view).to receive(:fixity_checkable?).and_return(false)
    allow(view).to receive(:virus_checkable?).and_return(false)
    allow(view).to receive(:link_to_unless_current).and_return("unneeded")
  end

  describe "published to public interface?" do
    let(:object) { ObjectInfoable.new(pid: 'test:1') }
    context "object is published" do
      before { object.publish! }
      it "should display 'Yes'" do
        render partial: 'application/object_info', locals: { current_object: object }
        expect(rendered).to match /(?<!Not )Published/
      end
    end
    context "object is not published" do
      it "should display 'No'" do
        render partial: 'application/object_info', locals: { current_object: object }
        expect(rendered).to match /Not Published/
      end
    end
  end

  describe "original filename" do
    before { allow(view).to receive(:current_object) { object } }
    context "object can have content" do
      let(:object) { ContentObjectInfoable.new(pid: 'test:1') }
      it "should display the 'Original Filename' label" do
        render partial: 'application/object_info', locals: { current_object: object }
        expect(rendered).to match /Original Filename/
      end
    end
    context "object cannot have content" do
      let(:object) { ObjectInfoable.new(pid: 'test:1') }
      it "should not display original filename" do
        render partial: 'application/object_info', locals: { current_object: object }
        expect(rendered).to_not match /Original Filename/
      end
    end
  end

end
