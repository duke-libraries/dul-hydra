require 'spec_helper'

module DulHydra
  describe Validations do
    before(:all) do
      class Validatable < ActiveFedora::Base
        include DulHydra::Validations
        has_metadata name: 'descMetadata', type: DulHydra::Datastreams::DescriptiveMetadataDatastream
        has_attributes :title, datastream: 'descMetadata', multiple: false

        def to_solr(solr_doc={}, opts={})
          solr_doc = super(solr_doc, opts)
          solr_doc.merge!(ActiveFedora::SolrService.solr_name(:title, :stored_sortable))
          solr_doc
        end
      end
      @obj = Validatable.new(pid: "foobar:1", title: "I am Validatable")
    end
    describe "validating uniqueness" do
      let(:taken) { double("another record") }
      before(:all) { Validatable.validates_uniqueness_of :title, index_type: :stored_sortable }
      after(:all) { Validatable.clear_validators! }
      context "on a new record" do
        context "when the value is not taken" do
          before { allow(Validatable).to receive(:where).with("title_ssi" => "I am Validatable") { [] } }
          it "should be valid" do
            expect(@obj).to be_valid
          end
        end
        context "when the value is taken" do
          before { allow(Validatable).to receive(:where).with("title_ssi" => "I am Validatable") { [taken] } }
          it "should not be valid" do
            expect(@obj).not_to be_valid
          end
        end
      end
      context "on a persisted record" do
        before { allow(@obj).to receive(:persisted?) { true } }
        context "when the value is not taken" do
          before do
            allow(Validatable).to receive(:where).with("title_ssi" => "I am Validatable", "-id" => "foobar:1") { [] }
          end
          it "should be valid" do
            expect(@obj).to be_valid
          end
        end
        context "when the value is taken by another record" do
          before do
            allow(Validatable).to receive(:where).with("title_ssi" => "I am Validatable", "-id" => "foobar:1") { [taken] } 
          end
          it "should not be valid" do
            expect(@obj).not_to be_valid
          end
        end
      end
    end
  end
end
