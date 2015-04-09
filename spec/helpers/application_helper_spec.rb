require 'spec_helper'

RSpec.describe ApplicationHelper, type: :helper do

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
  
end