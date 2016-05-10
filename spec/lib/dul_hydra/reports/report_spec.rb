module DulHydra::Reports
  RSpec.describe Report do

    describe "initialization" do
      describe "default" do
        its(:title) { is_expected.to eq "Report" }
      end
      describe "with a block" do
        subject {
          described_class.new { q "*:*" }
        }
        it "passes the block to a query builder and sets the report query" do
          expect(subject.query.q).to eq "*:*"
        end
      end
    end

    describe "#run" do
      it "returns a CSVQueryResult" do
        expect(subject.run).to be_a(Ddr::Index::CSVQueryResult)
      end
    end

    describe "#filename" do
      subject { described_class.new(title: "It's about that time!") }
      it "is a sanitized version of the report title with .csv extension" do
        expect(subject.filename).to eq "It_s_about_that_time_.csv"
      end
    end

  end
end
