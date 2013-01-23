require 'spec_helper'

shared_examples "an object that has preservation events" do

  context "new" do
    subject { described_class.new }
    its(:preservation_events) { should be_kind_of(Array) }
    its(:fixity_checks) { should be_kind_of(Array) }
  end

  context "validate_checksum" do
    let (:obj) { described_class.create.reload }
    after { obj.delete }
    subject { obj.validate_checksum("DC") }
    it { should be_kind_of(PreservationEvent) }
    its(:event_type) { should eq(PreservationEvent::FIXITY_CHECK) }
  end

  context "validate_checksum!" do
    let (:obj) { described_class.create.reload }
    before { obj.validate_checksum!("DC") }
    after do
      obj.fixity_checks.each { |e| e.delete }
      obj.delete
    end
    subject { obj.fixity_checks.first }
    its(:fixity_check?) { should be_true }
    its(:event_type) { should eq(PreservationEvent::FIXITY_CHECK) }
    its(:event_outcome) { should eq(PreservationEvent::SUCCESS) }
    its(:event_id_type) { should eq("UUID") }
    its(:linking_object_id_type) { should eq("datastream") }
    its(:linking_object_id_value) { should eq("#{obj.internal_uri}/datastreams/DC?asOfDateTime=" + obj.datastreams["DC"].dsCreateDate.strftime("%Y-%m-%dT%H:%M:%S.%LZ")) }
  end  

end
