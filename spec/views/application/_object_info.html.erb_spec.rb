require 'spec_helper'

RSpec.describe 'application/_object_info.html.erb', type: :view do

  before(:all) do
    class ObjectInfoable < ActiveFedora::Base
      include Ddr::Models::EventLoggable
      include Ddr::Models::HasAdminMetadata
    end
  end

  context "published to public interface?" do

    before do
      allow(view).to receive(:fixity_checkable?).and_return(false)
      allow(view).to receive(:virus_checkable?).and_return(false)
      allow(view).to receive(:link_to_unless_current).and_return("unneeded")
    end

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

end
