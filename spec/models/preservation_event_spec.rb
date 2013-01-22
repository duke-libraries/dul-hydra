require 'spec_helper'
require 'shared_examples_for_governables'
require 'shared_examples_for_access_controllables'

describe PreservationEvent do

  it_behaves_like "an access controllable object"
  it_behaves_like "a governable object"

  context "#new" do
    let(:obj) { PreservationEvent.new }
    it "should have an eventMetadata datastream" do
      obj.datastreams["eventMetadata"].should be_kind_of(DulHydra::Datastreams::PremisEventDatastream)
    end
  end

  context "::validate_checksum" do
    let!(:obj) { FactoryGirl.create(:component_with_content) }
    after { obj.delete }
    context "success" do
      subject { PreservationEvent.validate_checksum(obj, "content") }
      it { should be_kind_of(PreservationEvent) }
      its(:fixity_check?) { should be_true }
      its(:event_type) { should eq(PreservationEvent::FIXITY_CHECK) }
      its(:event_outcome) { should eq(PreservationEvent::SUCCESS) }
      its(:event_id_type) { should eq("UUID") }
      its(:linking_object_id_type) { should eq("datastream") }
      its(:linking_object_id_value) { should eq("#{obj.internal_uri}/datastreams/content?asOfDateTime=" + obj.datastreams["content"].dsCreateDate.strftime("%Y-%m-%dT%H:%M:%S.%LZ")) }
    end
    context "failure" do
      before do
        # Override datastream method #dsChecksumValid to always return false
        class << obj.datastreams["content"]
          def dsChecksumValid
            false
          end
        end
      end
      subject { PreservationEvent.validate_checksum(obj, "content") }
      it { should be_kind_of(PreservationEvent) }
      its(:fixity_check?) { should be_true }
      its(:event_type) { should eq(PreservationEvent::FIXITY_CHECK) }
      its(:event_outcome) { should eq(PreservationEvent::FAILURE) }
      its(:event_id_type) { should eq("UUID") }
      its(:linking_object_id_type) { should eq("datastream") }
      its(:linking_object_id_value) { should eq("#{obj.internal_uri}/datastreams/content?asOfDateTime=" + obj.datastreams["content"].dsCreateDate.strftime("%Y-%m-%dT%H:%M:%S.%LZ")) }
    end
  end

end
