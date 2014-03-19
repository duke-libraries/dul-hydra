require 'spec_helper'

describe "BatchFixityCheck", fixity_check: true do
  let(:report) { Tempfile.new('batch_fixity_check_spec') }
  let!(:bfc) { DulHydra::Scripts::BatchFixityCheck.new(report: report.path) }
  after do
    report.close!
    ActiveFedora::Base.destroy_all
  end
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
    expect(@obj1.fixity_checks.count).to eq(1)
    expect(@obj2.fixity_checks.count).to eq(1)
    expect(@obj3.fixity_checks.count).to eq(2)
    expect(@obj4.fixity_checks.count).to eq(1)
    expect(PreservationEvent.events_for(@obj5.pid).count).to eq(0)
    expect(bfc.total).to eq(2)
    expect(bfc.outcome_counts[PreservationEvent::SUCCESS]).to eq(2)
  end
  describe "the report" do
    let(:obj) { @obj3 }
    let(:csv) { CSV.read(report.path, headers: true) }
    it "should have a header row" do
      expect(csv.headers).to eq(['PID', 'Datastream', 'dsVersionID', 'dsCreateDate', 'dsChecksumType', 'dsChecksum', 'dsChecksumValid'])
    end
    it "should have rows for all datastreams that have content" do
      # expect(obj.datastreams["DC"]).to have_content
      # XXX A bug in ActiveFedora or Rubydora causes the DC datastream to appear initially empty
      expect(obj.datastreams.select {|dsid, ds| ds.has_content?}.keys)
        .to match_array(csv.select {|row| row["PID"] == obj.pid}.collect {|row| row["Datastream"]})
    end
    it "should not have rows for datastreams have do not have content" do
      expect(csv.select {|row| row["PID"] == obj.pid}.collect {|row| row["Datastream"]})
        .not_to include(obj.datastreams.reject {|dsid, ds| ds.has_content?})
    end
  end
end
