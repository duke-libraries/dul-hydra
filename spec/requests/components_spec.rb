require 'spec_helper'

describe "Components" do

  describe "GET /components" do

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

  end

  # describe "POST /components" do

  #   it "should create a collection" do
  #     visit new_component_path
  #     fill_in "Pid", :with => @pid1
  #     click_button "Create Component"
  #     page.should have_content "Added Component"
  #     page.should have_content @pid1
  #   end

  # end

end

