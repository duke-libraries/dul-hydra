require 'spec_helper'

shared_examples "a catalog index view" do
  it "should display the PID, model, title and identifier(s)" do
    expect(subject).to have_content(object.pid)
    expect(subject).to have_content(object.class.to_s)
    expect(subject).to have_content(object.title_display)
    expect(subject).to have_content(object.identifier.first)
    expect(subject).to have_css(".thumbnail")
  end
end

describe "catalog/index.html.erb" do
  subject { page }
  let(:object) { FactoryGirl.create(:test_content_thumbnail) }
  after { object.delete }
  context "search by title" do
    before do
      visit catalog_index_path
      fill_in "q", :with => object.title.first
      click_button "search"
    end
    it_behaves_like "a catalog index view"
  end
  context "search by identifier" do
    pending
  end
end
