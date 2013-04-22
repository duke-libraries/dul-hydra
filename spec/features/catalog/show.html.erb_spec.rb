require 'spec_helper'
require 'helpers/features_helper'

RSpec.configure do |c|
  c.include FeaturesHelper
end

describe "catalog/show.html.erb" do
  subject { page }
  before { visit catalog_path(object) }
  after do
    object.parent.delete if object.respond_to?(:parent) && object.parent
    if object.respond_to?(:children) && object.children
      object.children.each do |child|
        child.delete
      end
      object.reload
    end
    object.admin_policy.delete if object.admin_policy
    if object.respond_to?(:targets) && object.targets
      object.targets.each do |target|
        target.delete
      end
      object.reload
    end
    object.delete
  end
  context "Basic object" do
    let(:object) { FactoryGirl.create(:collection_public_read) }
    it "should display the PID, model, title and identifier(s)" do
      expect(subject).to have_content(object.pid)
      expect(subject).to have_content(object.class.to_s)
      expect(subject).to have_content(object.title_display)
      expect(subject).to have_content(object.identifier.first)
    end
    it "should link to all datastreams" do
      object.datastreams.reject { |dsid, ds| ds.profile.empty? }.each do |dsid, ds|
        expect(subject).to have_content(dsid)
      end
    end  
    it "should link to its audit trail" do
      expect(subject).to have_link("Audit Trail", :href => audit_trail_index_path(object))
    end
  end
  context "Object has a parent" do
    let(:object) { FactoryGirl.create(:item_in_collection_public_read) }
    it "should display its parent object" do
      #expect(subject).to have_link(object.parent.title_display, :href => catalog_path(object.parent))
      expect(subject).to have_content(object.parent.title_display)
    end
  end
  # inline display of children is now deprecated in favor of displaying children on a separate page
  # see context "object can have children" for tests related to displaying the link to the children page on this page
  #context "Object has children" do
  #  context "Object has contentMetadata datastream" do
  #    let(:object) { FactoryGirl.create(:test_content_metadata_has_children) }
  #    it "should should display the children in proper order" do
  #      expect(subject).to have_link("DulHydra Test Child Object", catalog_path(object.children.first.pid))
  #      expect(subject).to have_link("DulHydra Test Child Object", catalog_path(object.children[1].pid))
  #      expect(subject).to have_link("DulHydra Test Child Object", catalog_path(object.children.last.pid))
  #      catalog_path(object.children.last.pid).should appear_before(catalog_path(object.children.first.pid))
  #    end
  #  end
  #end
  context "object can have children" do
    context "object has children" do
      let (:object) { FactoryGirl.create(:test_parent_has_children) }
      it "should have a link to the list of its children" do
        expect(subject).to have_link("Children", :href => children_path(object))
      end
    end
    context "object does not have children" do
      let (:object) { FactoryGirl.create(:test_parent) }
      it "should not have a link to children" do
        expect(subject).to_not have_link("Children", :href => children_path(object))
      end
    end
  end
  context "Object has preservation events" do
    let(:object) { FactoryGirl.create(:component_with_content_public_read) }
    let(:preservation_event) { object.fixity_check! }
    before do
      preservation_event.permissions = [DulHydra::Permissions::PUBLIC_READ_ACCESS]
      preservation_event.save!
    end
    after { preservation_event.delete }
    it "should have a link to the list of associated preservation events" do
      expect(subject).to have_link("Preservation Events", :href => preservation_events_path(object))
    end
  end
  context "object has a thumbnail" do
    let(:object) { FactoryGirl.create(:test_content_thumbnail) }
    it "should display the thumbnail" do
      expect(subject).to have_css(".img-polaroid")
    end
  end
  context "object has admin policy" do
    let(:object) { FactoryGirl.create(:collection_public_read) }
    let(:apo) { FactoryGirl.create(:public_read_policy) }
    before do
      object.admin_policy = apo
      object.save!
    end
    after { apo.delete }
    it "should display its admin policy PID" #do
#      expect(subject).to have_content(object.admin_policy.pid)
#    end
  end
  context "object can have targets" do
    context "object has target" do
      let (:object) { FactoryGirl.create(:collection_has_target_public_read) }
      it "should have a link to the list of associated targets" do
        expect(subject).to have_link("Targets", :href => targets_path(object))
      end
    end
    context "object does not have target" do
      let (:object) { FactoryGirl.create(:collection_public_read) }
      it "should not have a link to targets" do
        expect(subject).to_not have_link("Targets", :href => targets_path(object))
      end
    end
  end
end
