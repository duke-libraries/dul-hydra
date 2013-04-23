require 'spec_helper'

describe "FixityCheck" do
  before do
    obj1.fixity_check! # last fixity check is now
    obj2.fixity_check! # last fixity check is now
    fc = obj3.fixity_check # last fixity check one year ago
    fc.event_date_time = PreservationEvent.to_event_date_time(Time.now.ago(1.year).utc)
    fc.save
    # fc.for_object.update_index
    bfc.execute
  end
  after do
    # Call destroy to trigger before_destroy callback to delete preservation events
    [obj1, obj2, obj3].each { |obj| obj.destroy }
  end
  let(:obj1) { FactoryGirl.create(:component_with_content) }
  let(:obj2) { FactoryGirl.create(:component_with_content) }
  let(:obj3) { FactoryGirl.create(:component_with_content) }
  let(:bfc) { DulHydra::Scripts::BatchFixityCheck.new }
  it "should run fixity checks on objects" do
    obj1.fixity_checks.to_a.size.should == 1
    obj2.fixity_checks.to_a.size.should == 1
    obj3.fixity_checks.to_a.size.should == 2
    bfc.summary[:total].should == 1
    bfc.summary[:success].should == 1
    bfc.summary[:failure].should == 0
  end
end
