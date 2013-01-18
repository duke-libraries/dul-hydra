require 'spec_helper'
require 'shared_examples_for_has_preservation_events'

shared_examples "a fixity checkable object" do

  it_behaves_like "an object that has preservation events"

  context "new" do
    subject { described_class.new }
    its(:fixity_checks) { should be_kind_of(Array) }
  end
  # context "persisted" do
    # before do
    #   @obj = described_class.create
    #   @obj.reload if @obj.respond_to?(:reload)
    # end
    # after { @obj.delete }
    # it "should have checksums enabled" do
    #   @obj.datastreams["DC"].profile["dsChecksumType"].should_not eq("DISABLED")
    # end
  context "validate_ds_checksum" do
    let (:obj) { described_class.create.reload }
    subject { obj.validate_ds_checksum(obj.datastreams["DC"]) }
    it { should be_kind_of(PreservationEvent) }
    its(:event_type) { should eq(PreservationEvent::FIXITY_CHECK) }
  end
  context "validate_ds_checksum!" do
    let (:obj) { described_class.create.reload }
    before { obj.validate_ds_checksum!(obj.datastreams["DC"]) }
    after { obj.fixity_checks.each { |e| e.delete } }
    subject { obj.fixity_checks.first }
    its(:fixity_check?) { should be_true }
    its(:event_type) { should eq(PreservationEvent::FIXITY_CHECK) }
    its(:event_outcome) { should eq("PASSED") }
    its(:event_id_type) { should eq("UUID") }
    its(:linking_object_id_type) { should eq("datastream") }
    its(:linking_object_id_value) { should eq("#{obj.internal_uri}/datastreams/DC?asOfDateTime=" + obj.datastreams["DC"].dsCreateDate.strftime("%Y-%m-%dT%H:%M:%S.%LZ")) }
  end
    #
    # TODO
    #
    # - linking_object_id_value can be used to retrieve exact version of datastream 
    # - changing file outside Fedora causes fixity check to fail
    #
  # end

end
