require 'spec_helper'

describe "children/index.html.erb" do
  subject { page }
  after do
    object.children.each { |c| c.delete }
    object.reload # work around https://github.com/projecthydra/active_fedora/issues/36
    object.delete
  end
  context "parent has contentMetadata datastream" do
    let(:object) { FactoryGirl.create(:test_content_metadata_has_children) }
    before { visit children_path(object) }
    it "should should display the children in proper order" do
      expect(subject).to have_link("DulHydra Test Child Object", catalog_path(object.children.first.pid))
      expect(subject).to have_link("DulHydra Test Child Object", catalog_path(object.children[1].pid))
      expect(subject).to have_link("DulHydra Test Child Object", catalog_path(object.children.last.pid))
      catalog_path(object.children.last.pid).should appear_before(catalog_path(object.children.first.pid))
    end    
  end
  context "parent does not have contentMetadata datastream" do
    let(:object) { FactoryGirl.create(:test_parent) }
    before do
      @child2 = TestChild.create(:identifier => "child002")
      @child2.parent = object
      @child2.save
      @child1 = TestChild.create(:identifier => "child001")
      @child1.parent = object
      @child1.save
      @child3 = TestChild.create(:identifier => "child003")
      @child3.parent = object
      @child3.save
      visit children_path(object)
    end
    it "should link to the parent and list the children associated with the parent" do
      expect(subject).to have_link(object.title_display, :href => catalog_path(object))
      object.children.each do |child|
        expect(subject).to have_link(child.title_display, :href => catalog_path(child))
        expect(subject).to have_content(child.pid)
        child.identifier.each do |identifier|
          expect(subject).to have_content(identifier)
        end
      end
      catalog_path(@child1.pid).should appear_before(catalog_path(@child2.pid))
    end    
  end
end
