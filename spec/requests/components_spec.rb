require 'spec_helper'

describe "Components" do

  describe "list" do

    before do
      @pid1 = "component:1"
      @pid2 = "component:2"
      @component1 = Component.create(:pid => @pid1)
      @component2 = Component.create(:pid => @pid2)
    end

    after do
      @component1.delete
      @component2.delete
    end

    it "should display a list of all components" do
      visit components_path
      page.should have_content @pid1
      page.should have_content @pid2
    end

  end # list components

  # describe "create" do

  #   it "should have a content datastream" do
  #     visit new_component_path
  #     attach_file "Content", "spec/fixtures/library-devil.tiff"
  #     click_button "Create Component"
  #     @component.datastreams["content"].should_not be_nil
  #   end

  #   after do
  #     @component.delete
  #   end

  # end

end

