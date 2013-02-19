require 'spec_helper'

describe "catalog/preservation_events.html.erb" do
  let(:object) { FactoryGirl.create(:component_with_content_public_read) }
  before { object.validate_content_checksum! }
  pending
end
