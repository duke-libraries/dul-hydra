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
    fill_in "q", :with => @component_identifier
    select "Identifier", :from => "search_field"
    click_button "search"
    page.should have_content(@component_title)
  end
end
