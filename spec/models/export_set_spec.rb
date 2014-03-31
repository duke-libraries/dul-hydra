require 'spec_helper'

describe ExportSet, export_sets: true do
  
  context "validation" do
    subject { export_set.errors.messages }
    let(:export_set) { ExportSet.new }

    context "default" do
      before { export_set.valid? }
      its([:user]) { should == ["can't be blank"] }
      its([:pids]) { should == ["can't be blank"] }
      its([:export_type]) { should == ["is not included in the list"] }
    end

    context "has pids" do
      before do
        export_set.pids = ["foo:bar"]
        export_set.valid?
      end
      its([:pids]) { should be_nil }
    end

    context "has user" do
      before do
        export_set.user = User.new
        export_set.valid?
      end
      its([:user]) { should be_nil }
    end

    context "invalid export type" do
      before do
        export_set.export_type = "foo"
        export_set.valid?
      end
      its([:export_type]) { should == ["is not included in the list"] }
    end

    context "description metadata type" do
      before { export_set.export_type = ExportSet::Types::DESCRIPTIVE_METADATA }
      context "default" do
        before { export_set.valid? }
        its([:export_type]) { should be_nil }
        its([:csv_col_sep]) { should == ["is not included in the list"] }
      end
      context "invalid csv_col_sep" do
        before do
          export_set.csv_col_sep = "foo"
          export_set.valid?
        end
        its([:csv_col_sep]) { should == ["is not included in the list"] }
      end
      context "valid csv_col_sep" do
        before do
          export_set.csv_col_sep = "tab"
          export_set.valid?
        end
        its([:csv_col_sep]) { should be_nil }
      end
    end
    context "content export_type" do
      before do
        export_set.export_type = ExportSet::Types::CONTENT 
        export_set.valid?
      end
      its([:export_type]) { should be_nil }
    end
  end
  
end
