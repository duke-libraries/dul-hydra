require 'spec_helper'

describe "Items" do

  describe "list items" do
    
    before do
      @item1 = Item.create
      @item2 = Item.create
    end

    after do
      @item1.delete
      @item2.delete
    end

    it "should display a list of all items" do
      visit items_path
      page.should have_content(@item1.pid)
      page.should have_content(@item2.pid)
    end

  end # list items

  describe "show item" do

    before do
      @item = Item.create
      @component1 = Component.create
      @component1.item = @item
      @component1.save
      @component2 = Component.create
      @component2.item = @item
      @component2.save
    end

    after do
      @item.delete
      @component1.delete
      @component2.delete
    end

    it "should display the item pid" do
      visit item_path(@item)
      page.should have_content(@item.pid)
    end

    it "should display the pids of the item's parts" do
      visit item_path(@item)
      page.should have_content(@component1.pid)
      page.should have_content(@component2.pid)
    end

  end # show item

end
