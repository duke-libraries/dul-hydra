require 'spec_helper'

describe "Components" do

  before(:all) do
    @filepath = "spec/fixtures/library-devil.tiff"
  end
  
  describe "list" do
    before do
      @component1 = Component.create
      @component2 = Component.create
    end
    after do
      Component.find_each { |c| c.delete }
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
    end
    after do
      Component.find_each { |c| c.delete }
      Item.find_each { |i| i.delete }
    end
    it "should be able the associate the component with an item" do
      item = Item.create
      visit component_path(@component)
      fill_in "Container", :with => item.pid
      click_button "Add Component to Item"
      component = Component.find(@component.pid)
      component.container.should_not be_nil
      component.container.pid.should eq(item.pid)
      i = Item.find(item.pid)
      i.parts.should_not be_empty
      i.part_ids.should include(@component.pid)
    end
    it "should be able to add content to the component" do # issue 35
      visit component_path(@component)
      attach_file "Content", @filepath
      click_button "Add content"
      page.should have_content "Content added"
      component = Component.find(@component.pid)
      component.content.size.should eq(File.size(@filepath))
    end
    it "should display information about the content" do
      @component.add_content(File.new(@filepath))
      visit component_path(@component)
      page.should have_content @component.content.mimeType
      page.should have_content @component.content.size
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

