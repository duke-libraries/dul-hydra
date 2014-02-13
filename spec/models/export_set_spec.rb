require 'spec_helper'

shared_examples "a valid export set" do
  it "should be valid" do
    expect(export_set).to be_valid
  end
end

shared_examples "an invalid export set" do
  it "should be valid" do
    expect(export_set).to_not be_valid
  end
end

describe ExportSet do
  
  context "validation" do
    context "csv_col_sep" do
      after { export_set.user.destroy }
      context "missing" do
        context "type is descriptive metadata" do
          let(:export_set) { FactoryGirl.build(:descriptive_metadata_export_set_with_pids) }
          it_behaves_like "an invalid export set"
        end
        context "type is content" do
          let(:export_set) { FactoryGirl.build(:content_export_set_with_pids) }
          it_behaves_like "a valid export set"
        end
      end
      context "present" do
        context "type is descriptive metadata" do
          let(:export_set) { FactoryGirl.build(:descriptive_metadata_export_set_with_pids) }
          before { export_set.csv_col_sep = "||" }
          it_behaves_like "a valid export set"
        end
      end
    end
  end
  
end