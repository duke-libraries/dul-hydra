require 'spec_helper'
require 'rake'

describe "Upgrade Export Sets" do
  let(:run_rake_task) do
    Rake::Task['dul_hydra:upgrade:export_sets'].reenable
    Rake::Task['dul_hydra:upgrade:export_sets'].invoke    
  end
  before do
    load File.expand_path("#{Rails.root}/lib/tasks/dul_hydra.rake", __FILE__)
    Rake::Task.define_task(:environment)    
  end
  after do
    export_set.user.destroy
    export_set.destroy
  end
  context "export_type blank" do
    let(:export_set) { FactoryGirl.create(:content_export_set_with_pids) }
    before do
      export_set.export_type = nil
      export_set.save
      run_rake_task
      export_set.reload
    end
    it "should set the export_type to ExportSet::Types::CONTENT" do
      expect(export_set.export_type).to eq(ExportSet::Types::CONTENT)
    end
  end
  context "missing csv_col_sep for descriptive metadata export set" do
    let(:export_set) { FactoryGirl.create(:descriptive_metadata_export_set_with_pids_with_csv_col_sep) }
    before do
      # have to stub ExportSet.export_descriptive_metadata? in order to thwart model validation
      # and set up the initial condition for this test
      ExportSet.any_instance.stub(:export_descriptive_metadata?).and_return(false)
      export_set.csv_col_sep = nil
      export_set.save
      ExportSet.any_instance.unstub(:export_descriptive_metadata?)
      run_rake_task
      export_set.reload
    end
    it "should set csv_col_sep to 'tab" do
      expect(export_set.csv_col_sep).to eq('tab')
    end    
  end
end