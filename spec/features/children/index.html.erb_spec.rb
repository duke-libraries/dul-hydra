require 'spec_helper'

describe "children/index.html.erb" do
  subject { page }
  let(:object) { FactoryGirl.create(:test_content_metadata_has_children) }
  before { visit children_path(object) }
  after do
    object.children.each { |c| c.delete }
    object.reload # work around https://github.com/projecthydra/active_fedora/issues/36
    object.delete
  end
  it "should should display the children in proper order" do
    expect(subject).to have_link("DulHydra Test Child Object", fcrepo_admin.object_path(object.children.first))
    expect(subject).to have_link("DulHydra Test Child Object", fcrepo_admin.object_path(object.children[1]))
    expect(subject).to have_link("DulHydra Test Child Object", fcrepo_admin.object_path(object.children.last))
    fcrepo_admin.object_path(object.children.last).should appear_before(fcrepo_admin.object_path(object.children.first))
  end    
end
