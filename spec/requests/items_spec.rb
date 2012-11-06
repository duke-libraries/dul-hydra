require 'spec_helper'

describe "Items" do

  describe "list" do

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

  end # list

  describe "show" do

    before do
      @item = Item.create
    end

    after do
      @item.delete
    end

    it "should display the item pid" do
      visit item_path(@item)
      page.should have_content(@item.pid)
    end

    describe "not a member of a collection" do

      before do
        @collection = Collection.create
      end

      after do
        @collection.delete
      end

      it "should be able to become a member of a collection" do
        visit item_path(@item)
        #select @collection.pid, :from => :collection
        fill_in :collection, :with => @collection.pid
        click_button "Add Item to Collection"
        item = Item.find(@item.pid)
        item.collection.pid.should eq(@collection.pid)
        collection = Collection.find(@collection.pid)
        collection.item_ids.should include(@item.pid)
      end
      
    end

    describe "has parts" do

      before do
        @component = Component.create
        @item.parts << @component
      end

      after do
        @component.delete
      end

      it "should display the pids of the parts" do
        visit item_path(@item)
        page.should have_content(@component.pid)
      end

    end # has parts

  end # show

  describe "Add" do
    before do
      @default_pid_namespace = "changeme"
      @title = "Test Item"
      @identifier = "itemIdentifier"
    end
    after do
      Item.find_each { |i| i.delete }
    end
    it "should create an item with the provided metadata" do
      visit new_item_path
      fill_in "Title", :with => @title
      fill_in "Identifier", :with => @identifier
      click_button "Create Item"
      page.should have_content "Added Item"
      page.should have_content @title
      page.should have_content @identifier
      page.should have_content @default_pid_namespace
    end
  end
  
end
