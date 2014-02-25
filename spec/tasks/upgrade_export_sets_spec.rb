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
    let(:export_set) do
      ExportSet.new.tap do |es|
        es.export_type = ExportSet::Types::DESCRIPTIVE_METADATA
        es.pids = ["foo:bar"]
        es.user = FactoryGirl.create(:user)
      end
    end
    before do
      export_set.save(validate: false)
      run_rake_task
      export_set.reload
    end
    it "should set csv_col_sep to 'tab" do
      expect(export_set.csv_col_sep).to eq('tab')
    end    
  end
end
