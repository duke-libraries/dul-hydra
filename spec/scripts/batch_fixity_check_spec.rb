require 'spec_helper'

module DulHydra
  module Scripts
    describe BatchFixityCheck, fixity_check: true do
      let(:report) { Tempfile.new('batch_fixity_check_spec') }
      let!(:bfc) { described_class.new(report: report.path) }
      after { report.close! }
      context "with an object that was just checked" do
        let(:obj) { FactoryGirl.create(:component) }
        before { obj.fixity_check }
        it "should not check the object" do
          expect { bfc.execute }.not_to change{ obj.fixity_checks.count }
        end
      end
      context "with an object that has not previously been checked" do
        let!(:obj) { FactoryGirl.create(:component) }
        it "should check the object" do
          expect { bfc.execute }.to change{ obj.fixity_checks.count }.by(1)
        end
      end
      context "with an object that was last checked one year ago" do
        let!(:obj) { FactoryGirl.create(:component) }
        before do
          Ddr::Events::FixityCheckEvent.create(pid: obj.pid, event_date_time: Time.now.ago(1.year).utc)
        end
        it "should check the object" do
          expect { bfc.execute }.to change{ obj.fixity_checks.count }.by(1)
        end
      end
      describe "the report" do
        let(:csv) { CSV.read(report.path, headers: true) }
        let(:datastreams_with_content) { ["DC", "RELS-EXT", "descMetadata", "content", "thumbnail", "multiresImage", "adminMetadata", "structMetadata"] }
        before do
          @objects = FactoryGirl.create_list(:component, 5)
          bfc.execute 
        end
        it "should have a header row" do
          expect(csv.headers).to eq(['PID', 'Datastream', 'dsVersionID', 'dsCreateDate', 'dsChecksumType', 'dsChecksum', 'dsChecksumValid'])
        end
        it "should have rows for all datastreams that have content" do
          @objects.each do |obj|
            rows_for_object = csv.select {|row| row["PID"] == obj.pid}
            expect(rows_for_object.collect {|row| row["Datastream"]})
              .to match_array(datastreams_with_content)
          end
        end
        it "should have appropriate column values" do
          csv.each do |row|
            expect(row["PID"]).to match(/^[a-z]+:\d+$/)
            expect(datastreams_with_content).to include(row["Datastream"])
            expect(row["dsVersionID"]).to match(/^#{row["Datastream"]}/)
            createDate = Time.parse(row["dsCreateDate"])
            expect(createDate).to be_a Time
            expect(createDate).to_not be_utc
            expect(row["dsChecksumType"]).to eq("SHA-256")
            expect(row["dsChecksum"]).to match(/^\h{64}$/)
            expect(row["dsChecksumValid"]).to match(/^(true|false)$/)
          end
        end
      end
    end
  end
end
