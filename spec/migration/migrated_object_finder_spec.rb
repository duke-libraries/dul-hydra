require 'migration_helper'
require 'active_fedora/cleaner'

module DulHydra::Migration
  RSpec.describe MigratedObjectFinder do

    subject { described_class }

    before { ActiveFedora::Cleaner.clean! }

    describe ".find" do
      let(:object) { FactoryGirl.create(:item) }
      let(:fc3_pid) { "test:12345" }
      let(:fc3_uri) { RDF::URI.new("info:fedora/#{fc3_pid}") }
      describe "when called with a Fedora 3 PID" do
        describe "when a corresponding object exists" do
          before do
            object.fcrepo3_pid = fc3_pid
            object.save!
          end
          it "should return the object" do
            expect(described_class.find(fc3_pid)).to eq(object)
          end
        end
        describe "when a corresponding object does not exist" do
          it "should return nil" do
            expect(described_class.find(fc3_pid)).to be_nil
          end
        end
      end
      describe "when called with a Fedora 3 URI" do
        describe "when a corresponding object exists" do
          before do
            object.fcrepo3_pid = fc3_pid
            object.save!
          end
          it "should return the object" do
            expect(described_class.find(fc3_uri)).to eq(object)
          end
        end
        describe "when a corresponding object does not exist" do
          it "should return nil" do
            expect(described_class.find(fc3_uri)).to be_nil
          end
        end
      end
    end

  end
end
