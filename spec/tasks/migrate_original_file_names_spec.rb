require 'spec_helper'
require 'rake'

describe "Migrate Original File Names" do

  let(:run_rake_task) do
    Rake::Task['dul_hydra:upgrade:original_file_names'].reenable
    Rake::Task['dul_hydra:upgrade:original_file_names'].invoke    
  end  
  let(:source) { "source attribute value" }
  before do
    load File.expand_path("#{Rails.root}/lib/tasks/dul_hydra.rake", __FILE__)
    Rake::Task.define_task(:environment)    
  end
  after { object.destroy }
  
  context "Component object" do
    let(:object) { FactoryGirl.create(:component) }
    context "has one source attribute" do
      before do
        object.source = source
        object.original_filename = nil
        object.save!(validate: false)
        run_rake_task
        object.reload
      end
      it "should have moved value from source to original_filename" do
        expect(object.source).to be_empty
        expect(object.original_filename).to include(source)
      end
    end
    context "has more than one source attribute" do
      before do
        object.source = [ source, "another source attribute value" ]
        object.original_filename = nil
        object.save!(validate: false)
        run_rake_task
        object.reload
        puts object.original_filename
      end
      it "should have not moved value from source to original_filename" do
        expect(object.source).to include(source)
        expect(object.original_filename).to be_nil
      end
    end
  end
  
  context "not HasContent object" do
    let(:object) { FactoryGirl.create(:test_model) }
    before do
      object.source = source
      object.save!(validate: false)
      run_rake_task
      object.reload
    end
    context "has source attribute" do
      it "should not have moved value from source to original_filename" do
        expect(object.source).to include(source)
        expect { object.original_filename }.to raise_error(NoMethodError)
      end
    end
  end

end