require 'spec_helper'

describe "Components" do

  describe "list" do

    before do
      @component1 = Component.create
      @component2 = Component.create
    end

    after do
      @component1.delete
      @component2.delete
    end

    it "should display a list of all components" do
      visit components_path
      page.should have_content @component1.pid
      page.should have_content @component2.pid
    end

  end # list components

  describe "show" do
    
    before do
      @component = Component.create
      @item = Item.create
    end

    after do
      @component.delete
      @item.delete
    end

    it "should be able the associate the component with an item" do
      visit component_path(@component)
      fill_in "Item", :with => @item.pid
      click_button "Add Component to Item"
      component = Component.find(@component.pid)
      component.item.should_not be_nil
      component.item.pid.should eq(@item.pid)
      item = Item.find(@item.pid)
      item.components.should_not be_empty
      item.component_ids.should include(@component.pid)
    end
    
  end # show

  # describe "create" do

  #   it "should display information about the content" do
  #     visit new_component_path
  #     attach_file "Content", "spec/fixtures/library-devil.tiff"
  #     click_button "Create Component"
  #     page.should have_content "Size"
  #   end

  #   after do
  #     Component.find_each { |c| c.delete }
  #   end

  # end

end

