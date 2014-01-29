require 'spec_helper'

describe "FixityCheck", fixity_check: true do
  before do
    obj1.fixity_check! # last fixity check is now
    obj2.fixity_check! # last fixity check is now
    fc = obj3.fixity_check # last fixity check one year ago
    fc.event_date_time = PreservationEvent.to_event_date_time(Time.now.ago(1.year).utc)
    fc.save
    bfc.execute
  end
  after do
    # Call destroy to trigger before_destroy callback to delete preservation events
    [obj1, obj2, obj3].each { |obj| obj.destroy }
    report.close!
  end
  let(:obj1) { FactoryGirl.create(:component_with_content) }
  let(:obj2) { FactoryGirl.create(:component_with_content) }
  let(:obj3) { FactoryGirl.create(:component_with_content) }
  let(:report) { Tempfile.new('batch_fixity_check_spec') }
  let(:bfc) { DulHydra::Scripts::BatchFixityCheck.new(report: report.path) }
  it "should run fixity checks on objects" do
    obj1.fixity_checks.to_a.size.should == 1
    obj2.fixity_checks.to_a.size.should == 1
    obj3.fixity_checks.to_a.size.should == 2
    bfc.total.should == 1
    bfc.pids.first.should == obj3.pid
    bfc.outcome_counts[PreservationEvent::SUCCESS].should == 1
  end
end
