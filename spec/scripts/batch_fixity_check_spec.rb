require 'spec_helper'

describe "BatchFixityCheck", fixity_check: true do
  let(:report) { Tempfile.new('batch_fixity_check_spec') }
  let!(:bfc) { DulHydra::Scripts::BatchFixityCheck.new(report: report.path) }
  after { report.close! }
  describe "the process" do
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
    end
    let(:obj1) { FactoryGirl.create(:component_with_content) }
    let(:obj2) { FactoryGirl.create(:component_with_content) }
    let(:obj3) { FactoryGirl.create(:component_with_content) }
    it "should run fixity checks on objects" do
      obj1.fixity_checks.to_a.size.should == 1
      obj2.fixity_checks.to_a.size.should == 1
      obj3.fixity_checks.to_a.size.should == 2
      bfc.total.should == 1
      bfc.pids.first.should == obj3.pid
      bfc.outcome_counts[PreservationEvent::SUCCESS].should == 1
    end
  end
  describe "the report" do
    before do
      fc = obj.fixity_check # last fixity check one year ago
      fc.event_date_time = PreservationEvent.to_event_date_time(Time.now.ago(1.year).utc)
      fc.save
      bfc.execute
      # XXX This is brittle, but so is the report
      CSV.foreach(report.path) do |row|
        pid = row[0]
        report_map[pid] ||= []
        report_map[pid] << row[1]
      end
    end
    after do
      obj.destroy
    end
    let(:obj) { FactoryGirl.create(:component_with_content) }
    let!(:report_map) { {} }
    it "should have rows for all datastreams that have content" do
      obj.datastreams.select {|dsid, ds| ds.has_content?}.each do |dsid, ds|
        report_map[obj.pid].should include(dsid)
      end
    end
    it "should not have rows for datastreams have do not have content" do
      obj.datastreams.reject {|dsid, ds| ds.has_content?}.each do |dsid, ds|
        report_map[obj.pid].should_not include(dsid)
      end
    end
  end
end
