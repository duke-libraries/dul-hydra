require 'spec_helper'

shared_examples "a DulHydra object catalog index view" do
  it "should display the PID, model, title and identifier(s)" do
    expect(subject).to have_content(object.pid)
    expect(subject).to have_content(object.class.to_s)
    expect(subject).to have_content(object.title_display)
    expect(subject).to have_content(object.identifier.first)
  end
end

describe "catalog/index.html.erb" do
  subject { page }
  before do
    visit catalog_index_path
    fill_in "q", :with => object.title.first
    click_button "search"
  end
  after { object.delete }
  it_behaves_like "a DulHydra object catalog index view" do
    let(:object) { FactoryGirl.create(:component_public_read) }
  end
  it_behaves_like "a DulHydra object catalog index view" do
    let(:object) { FactoryGirl.create(:item_public_read) }
  end
  it_behaves_like "a DulHydra object catalog index view" do
    let(:object) { FactoryGirl.create(:item_public_read) }
  end
  it "should be able to find a Component by identifier"
end
