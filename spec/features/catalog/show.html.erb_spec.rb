require 'spec_helper'

def login(user)
  visit new_user_session_path
  fill_in 'Email', :with => user.email
  fill_in 'Password', :with => user.password
  click_button 'Sign in'
end

shared_examples "a DulHydra object catalog show view" do
  it "should display the PID, model, title and identifier(s)" do
    expect(subject).to have_content(object.pid)
    expect(subject).to have_content(object.class.to_s)
    expect(subject).to have_content(object.title_display)
    expect(subject).to have_content(object.identifier.first)
  end
  it "should list all datastreams" do
    object.datastreams.each do |dsid, ds|
      expect(subject).to have_content(dsid)
    end
  end  
  it "should have a link to its parent object, if relevant" do
    expect(subject).to have_link(object.parent.pid) if object.respond_to?(:parent)
  end
  it "should have links to its child objects, if relevant" do
    if object.respond_to?(:children)
      object.children.each do |child|
        expect(subject).to have_link(child.pid, :href => catalog_path(child))
      end
    end
  end
  it "should display its admin policy" do
    expect(subject).to have_content(object.admin_policy.pid)
  end
end

describe "catalog/show.html.erb" do
  subject { page }
  let(:user) { FactoryGirl.create(:user) }
  before(:each) do
    login user
    visit catalog_path(object)
  end
  after(:each) do
    object.parent.delete if object.respond_to?(:parent) && object.parent
    object.delete
  end
  after(:all) { user.delete }
  it_behaves_like "a DulHydra object catalog show view" do
    let(:object) { FactoryGirl.create(:collection_has_apo) }
  end
  it_behaves_like "a DulHydra object catalog show view" do
    let(:object) { FactoryGirl.create(:item_in_collection_has_apo) }
  end
  it_behaves_like "a DulHydra object catalog show view" do
    let(:object) { FactoryGirl.create(:component_part_of_item_has_apo) }
  end
end
