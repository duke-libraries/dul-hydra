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
    object.admin_policy.delete if object.admin_policy
    if object.respond_to?(:children)
      object.children.each { |c| c.delete }
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
    it "should list all datastreams" do
      object.datastreams.each do |dsid, ds|
        expect(subject).to have_content(dsid)
      end
    end  
  end
  context "Object has a parent" do
    let(:object) { FactoryGirl.create(:item_in_collection_public_read) }
    it "should have a link to its parent object" do
      expect(subject).to have_link(object.parent.pid)
    end
  end
  context "Object has children" do
    it "should have links to its child objects"
  #   let(:object) { FactoryGirl.create(:item_has_part_public_read) }
  #   it "should have links to its child objects" do
  #     object.children.each do |child|
  #       expect(subject).to have_link(child.pid, :href => catalog_path(child))
  #     end
  #   end
  end
  context "Object has preservation events" do
    let(:object) { FactoryGirl.create(:component_with_content) }
    before { object.validate_content_checksum! }
    after { object.preservation_events.each { |e| e.delete } }
    it "should have a link to the list of associated preservation events"
    # it { should have_link(object.preservation_events.first.pid, :href => catalog_path(object.preservation_events.first)) }
  end
  context "object has admin policy" do
    let(:object) { FactoryGirl.create(:collection_has_apo) }
    # XXX User authn works around https://github.com/projecthydra/hydra-head/issues/39
    let(:user) { FactoryGirl.create(:user) }
    before do 
      login user
      sleep 5
    end
    after { user.delete }
    it "should have a link to its admin policy" do
      pending "determination of cause of test failure"
      expect(subject).to have_link(object.admin_policy.pid, :href => catalog_path(object.admin_policy))
    end
  end
end
