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
    it "should display its parent object PID" do
      expect(subject).to have_content(object.parent.pid)
    end
  end
  context "Object has preservation events" do
    let(:object) { FactoryGirl.create(:component_with_content_public_read) }
    let(:preservation_event) { object.validate_content_checksum! }
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
end
