require 'spec_helper'

describe "Items" do

  after do
    Item.find_each { |i| i.delete }
  end

  describe "list" do
    it "should display PIDs for items without titles" do
      item1 = Item.create
      item2 = Item.create
      visit items_path
      page.should have_content(item1.pid)
      page.should have_content(item2.pid)
    end
    it "should display titles for items with titles" do
      item1 = Item.create(:title => "New Item 1")
      item2 = Item.create(:title => "New Item 2")
      visit items_path
      page.should have_content(item1.title.first)
      page.should have_content(item2.title.first)
    end
  end # list

  describe "show" do
    # before do
    #   @item = Item.create
    # end
    it "should display the item pid" do
      item = Item.create
      visit item_path(item)
      page.should have_content(item.pid)
    end

    describe "not a member of a collection" do
      after do
        Collection.find_each { |c| c.delete }
      end
      it "should be able to become a member of a collection" do
        collection = Collection.create
        item = Item.create
        visit item_path(item)
        fill_in :collection, :with => collection.pid
        click_button "Add Item to Collection"
        item_in_collection = Item.find(item.pid)
        item_in_collection.collection.should eq(collection)
        collection = Collection.find(collection.pid)
        collection.items.should include(item_in_collection)
      end
    end

    describe "has parts" do
      after do
        Component.find_each { |c| c.delete }
      end
      it "should display the pids of the parts" do
        item = Item.create
        component = Component.create
        item.parts << component
        visit item_path(item)
        page.should have_content(component.pid)
      end
    end # has parts

  end # show

  describe "Add" do
    it "should create an item with the provided metadata" do
      title = "Test Item"
      identifier = "itemIdentifier"
      visit new_item_path
      fill_in "Title", :with => title
      fill_in "Identifier", :with => identifier
      click_button "Create Item"
      page.should have_content "Added Item"
      page.should have_content title
      page.should have_content identifier
    end
  end # Add
  
end
