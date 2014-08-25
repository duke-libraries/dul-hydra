require 'spec_helper'

describe ExportSet, type: :model, export_sets: true do
  
  context "validation" do
    subject { export_set.errors.messages }
    let(:export_set) { ExportSet.new }

    context "default" do
      before { export_set.valid? }

      describe '[:user]' do
        subject { super()[:user] }
        it { is_expected.to eq(["can't be blank"]) }
      end

      describe '[:pids]' do
        subject { super()[:pids] }
        it { is_expected.to eq(["can't be blank"]) }
      end

      describe '[:export_type]' do
        subject { super()[:export_type] }
        it { is_expected.to eq(["is not included in the list"]) }
      end
    end

    context "has pids" do
      before do
        export_set.pids = ["foo:bar"]
        export_set.valid?
      end

      describe '[:pids]' do
        subject { super()[:pids] }
        it { is_expected.to be_nil }
      end
    end

    context "has user" do
      before do
        export_set.user = User.new
        export_set.valid?
      end

      describe '[:user]' do
        subject { super()[:user] }
        it { is_expected.to be_nil }
      end
    end

    context "invalid export type" do
      before do
        export_set.export_type = "foo"
        export_set.valid?
      end

      describe '[:export_type]' do
        subject { super()[:export_type] }
        it { is_expected.to eq(["is not included in the list"]) }
      end
    end

    context "description metadata type" do
      before { export_set.export_type = ExportSet::Types::DESCRIPTIVE_METADATA }
      context "default" do
        before { export_set.valid? }

        describe '[:export_type]' do
          subject { super()[:export_type] }
          it { is_expected.to be_nil }
        end

        describe '[:csv_col_sep]' do
          subject { super()[:csv_col_sep] }
          it { is_expected.to eq(["is not included in the list"]) }
        end
      end
      context "invalid csv_col_sep" do
        before do
          export_set.csv_col_sep = "foo"
          export_set.valid?
        end

        describe '[:csv_col_sep]' do
          subject { super()[:csv_col_sep] }
          it { is_expected.to eq(["is not included in the list"]) }
        end
      end
      context "valid csv_col_sep" do
        before do
          export_set.csv_col_sep = "tab"
          export_set.valid?
        end

        describe '[:csv_col_sep]' do
          subject { super()[:csv_col_sep] }
          it { is_expected.to be_nil }
        end
      end
    end
    context "content export_type" do
      before do
        export_set.export_type = ExportSet::Types::CONTENT 
        export_set.valid?
      end

      describe '[:export_type]' do
        subject { super()[:export_type] }
        it { is_expected.to be_nil }
      end
    end
  end
  
end
