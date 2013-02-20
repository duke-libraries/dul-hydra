require 'spec_helper'

describe "catalog/preservation_events/index.html.erb" do
  subject { page }
  let(:object) { FactoryGirl.create(:component_with_content_public_read) }
  let(:preservation_event) { object.validate_content_checksum! }
  before do
    preservation_event.permissions = [DulHydra::Permissions::PUBLIC_READ_ACCESS]
    preservation_event.save!
    visit catalog_preservation_events_path(object)
  end
  after do
    preservation_event.delete
    object.delete
  end
  it "should list the preservation events associated with the object" do
    expect(subject).to have_content(preservation_event.pid)
  end
end
