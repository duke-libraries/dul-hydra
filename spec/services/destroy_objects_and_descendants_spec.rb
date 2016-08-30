RSpec.describe DestroyObjectsAndDescendants do

  before {
    @collection = FactoryGirl.create(:collection)
    @item_no_children = FactoryGirl.create(:item)
    @item_with_children = FactoryGirl.create(:item, :has_part)
    @component = @item_with_children.children.first
    @collection.children << @item_no_children
    @collection.children << @item_with_children
    @collection.save!
  }

  specify {
    described_class.call([@collection.pid])
    expect { @collection.reload }.to raise_error(ActiveFedora::ObjectNotFoundError)
    expect { @component.reload }.to raise_error(ActiveFedora::ObjectNotFoundError)
    expect { @item_no_children.reload }.to raise_error(ActiveFedora::ObjectNotFoundError)
    expect { @item_with_children.reload }.to raise_error(ActiveFedora::ObjectNotFoundError)
  }

end
