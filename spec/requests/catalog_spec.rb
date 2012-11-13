require 'spec_helper'

describe "Catalog" do
  before(:all) do
    @component_identifier = "test010010010"
    @component_title = "Test Component"
    @component = Component.create(:title => @component_title, :identifier => @component_identifier)
  end
  after(:all) do
    @component.delete
  end
  it "should find a component by identifier" do # issue 34
    visit catalog_index_path
    select "Identifier", :from => "search_field"
    fill_in "q", :with => @component_identifier
    click_button "search"
    page.should have_content(@component_title)
  end
  it "should display PID, identifier, and model for each item in results" do
    visit catalog_index_path
    fill_in "q", :with => @component_title
    click_button "search"
    page.should have_content(@component.pid)
    page.should have_content(@component.identifier.first)
    page.should have_content("Component")
  end
end
