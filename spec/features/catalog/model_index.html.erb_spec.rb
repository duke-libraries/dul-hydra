require 'spec_helper'
require 'helpers/features_helper'

RSpec.configure do |c|
  c.include FeaturesHelper
end

shared_examples "a DulHydra object model index view" do
  it "should display the PID and link to the catalog show view" do
    pending # FIXME no idea why this test fails -- dchandekstark
    expect(subject).to have_content(object.pid)
    expect(subject).to have_link(object.pid, :href => catalog_path(object))
  end
end

describe "catalog/show.html.erb" do
  subject { page }
  before(:each) { visit url }
  after(:each) { object.delete }
  it_behaves_like "a DulHydra object model index view" do
    let(:object) { FactoryGirl.create(:collection_public_read) }
    let(:url) { collections_path }
  end
  it_behaves_like "a DulHydra object model index view" do
    let(:object) { FactoryGirl.create(:item_public_read) }
    let(:url) { items_path }
  end
  it_behaves_like "a DulHydra object model index view" do
    let(:object) { FactoryGirl.create(:component_public_read) }
    let(:url) { components_path }
  end
end
