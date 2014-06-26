require 'spec_helper'

module DulHydra
  module Scripts
    describe BatchFixityCheck, fixity_check: true do
      let(:report) { Tempfile.new('batch_fixity_check_spec') }
      let!(:bfc) { described_class.new(report: report.path) }
      after { report.close! }
      context "with an object that was just checked" do
        let(:obj) { FactoryGirl.create(:component) }
        before { obj.fixity_check! }
        it "should not check the object" do
          expect(obj.fixity_checks.count).to eq(1)
          expect { bfc.execute }.not_to change{ obj.fixity_checks.count }
        end
      end
      context "with an object that has not previously been checked" do
        let(:obj) { FactoryGirl.create(:component) }
        it "should check the object" do
          expect(obj.fixity_checks.count).to eq(0)
          expect { bfc.execute }.to change{ obj.fixity_checks.count }.by(1)
        end
      end
      context "with an object that was last checked one year ago" do
        let(:obj) { FactoryGirl.create(:component) }
        before do
          fc = obj.fixity_check
          fc.event_date_time = Time.now.ago(1.year).utc
          fc.save   
        end
        it "should check the object" do
          expect(obj.fixity_checks.count).to eq(1)
          expect { bfc.execute }.to change{ obj.fixity_checks.count }.by(1)
        end
      end
      context "with an object that doesn't have preservation events" do
        let(:obj) { FactoryGirl.create(:admin_policy) }
        it "should not check the object" do
          expect(obj).not_to receive(:fixity_check!)
          expect(obj).not_to receive(:fixity_check)
          bfc.execute
        end
      end
      describe "the report" do
        let(:csv) { CSV.read(report.path, headers: true) }
        let(:datastreams_with_content) { ["DC", "RELS-EXT", "descMetadata", "content", "thumbnail", "properties"] }
        before do
          @objects = FactoryGirl.create_list(:component_with_content, 5)
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
            expect(DateTime.parse(row["dsCreateDate"])).to be_a(DateTime)
            expect(row["dsChecksumType"]).to eq("SHA-256")
            expect(row["dsChecksum"]).to match(/^\h{64}$/)
            expect(row["dsChecksumValid"]).to match(/^(true|false)$/)
          end
        end
      end
    end
  end
end
