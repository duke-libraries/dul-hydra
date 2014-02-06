require 'spec_helper'

describe "BatchFixityCheck", fixity_check: true do
  let(:report) { Tempfile.new('batch_fixity_check_spec') }
  let!(:bfc) { DulHydra::Scripts::BatchFixityCheck.new(report: report.path) }
  before { ActiveFedora::Base.destroy_all }
  after do
    report.close!
    #ActiveFedora::Base.destroy_all
  end
  describe "the process", fixme: true do
    before do
      @obj1 = FactoryGirl.create(:component)
      @obj2 = FactoryGirl.create(:item)
      @obj3 = FactoryGirl.create(:collection)
      @obj4 = FactoryGirl.create(:target)
      @obj5 = FactoryGirl.create(:admin_policy)

      @obj1.fixity_check! # last fixity check is now
      @obj2.fixity_check! # last fixity check is now
      fc = @obj3.fixity_check # last fixity check one year ago
      fc.event_date_time = PreservationEvent.to_event_date_time(Time.now.ago(1.year).utc)
      fc.save
      bfc.execute
    end
    it "should run fixity checks on objects" do
      @obj1.fixity_checks.to_a.size.should == 1
      @obj2.fixity_checks.to_a.size.should == 1
      @obj3.fixity_checks.to_a.size.should == 2
      @obj4.fixity_checks.to_a.size.should == 1
      PreservationEvent.events_for(@obj5.pid).count.should == 0
      bfc.total.should == 2
      bfc.outcome_counts[PreservationEvent::SUCCESS].should == 2
    end
  end
  describe "the report" do
    let(:obj) { FactoryGirl.create(:component_with_content) }
    let!(:report_map) { {} }
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
