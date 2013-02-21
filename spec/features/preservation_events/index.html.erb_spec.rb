require 'spec_helper'

describe "preservation_events/index.html.erb" do
  subject { page }
  let(:object) { FactoryGirl.create(:test_content_with_fixity_check) }
  before { visit preservation_events_path(object) }
  after do
    object.preservation_events.each { |pe| pe.delete }
    object.reload # work around https://github.com/projecthydra/active_fedora/issues/36
    object.delete
  end
  it "should list the preservation events associated with the object" do
    object.preservation_events.each do |pe|
      expect(subject).to have_content(pe.pid)
    end
  end
end
