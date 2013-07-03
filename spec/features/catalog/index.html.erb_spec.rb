require 'spec_helper'

describe "catalog/index.html.erb" do
  subject { page }
  let(:object) { FactoryGirl.create(:test_content_thumbnail) }
  after { object.delete }
  it "should display thumbnails" do
    visit catalog_index_path
    fill_in "q", :with => object.title.first
    click_button "search"
    expect(subject).to have_xpath("//a[@href = \"#{catalog_path(object)}\"]/img[@src = \"#{fcrepo_admin.download_object_datastream_path(object, DulHydra::Datastreams::THUMBNAIL)}\"]")
  end
end
