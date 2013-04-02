require 'spec_helper'

describe "FixityCheck" do
  before do
    obj1.validate_content_checksum! # last fixity check is now
    obj2.validate_content_checksum! # last fixity check is now
    fc = obj3.validate_content_checksum # last fixity check one year ago
    fc.event_date_time = PreservationEvent.to_event_date_time(Time.now.ago(1.year).utc)
    fc.save!
    obj3.update_index
    DulHydra::Scripts::FixityCheck.execute
  end
  after do
    # Call destroy to trigger before_destroy callback to delete preservation events
    [obj1, obj2, obj3].each { |obj| obj.destroy }
  end
  let(:obj1) { FactoryGirl.create(:component_with_content) }
  let(:obj2) { FactoryGirl.create(:component_with_content) }
  let(:obj3) { FactoryGirl.create(:component_with_content) }
  it "should run fixity checks on objects" do
    obj1.fixity_checks.to_a.size.should == 1
    obj2.fixity_checks.to_a.size.should == 1
    obj3.fixity_checks.to_a.size.should == 2
  end
end
