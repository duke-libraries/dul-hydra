require 'spec_helper'
require 'shared_examples_for_describables'

describe Component do
  it_behaves_like "a describable"
  context "relationships" do
    before do
      @component = Component.create
      @item = Item.create
    end
    after do
      @item.delete
      @component.delete
    end
    context "when container set to item" do
      it "should be a part of the item" do
        @component.container = @item
        @component.save
        @item.parts.should include(@component)
      end
    end
    context "when added to item's parts" do
      it "should have the item as container" do
        @item.parts << @component
        @component.container.should eq(@item)
      end
    end
  end # relationships
end
