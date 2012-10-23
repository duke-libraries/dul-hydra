require 'spec_helper'

describe "Items" do

  describe "list items" do
    
    before do
      @item1 = Item.create(:pid => "item:1")
      @item2 = Item.create(:pid => "item:2")
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

  end

  describe "show item" do

    before do
      @item = Item.create(:pid => "item:1")
      @component1 = Component.create(:pid => "component:1")
      @component1.part_of_append(@item)
      @component1.save
      @component2 = Component.create(:pid => "component:2")
      @component2.part_of_append(@item)
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

  end


end
