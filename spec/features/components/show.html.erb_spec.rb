require 'spec_helper'

describe "show.html.erb" do

  subject { page }
  let(:component) { FactoryGirl.create(:component_part_of_item_with_content_has_apo) }
  before { visit component_path(component) }
  after do
    component.admin_policy.delete
    component.item.delete
    component.reload # work around https://github.com/projecthydra/active_fedora/issues/36
    component.delete
  end
  it { should have_content(component.pid) }
  it { should have_content(component.title.first) } 
  it { should have_content(component.identifier.first) }
  it { should have_link("DC") }
  it { should have_link("RELS-EXT") }
  it { should have_link("descMetadata") }
  it { should have_link("content") }
  
end
