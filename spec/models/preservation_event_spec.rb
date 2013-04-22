require 'spec_helper'
require 'support/shared_examples_for_governables'
require 'support/shared_examples_for_access_controllables'
require 'support/shared_examples_for_preservation_events'

# Override datastream method #dsChecksumValid to always return false
def ds_checksum_valid_false(ds)
  class << ds
    def dsChecksumValid; false; end
  end
end

describe PreservationEvent do

  it_behaves_like "an access controllable object"
  it_behaves_like "a governable object"

  context "#new" do
    let(:obj) { PreservationEvent.new }
    it "should have an eventMetadata datastream" do
      obj.datastreams["eventMetadata"].should be_kind_of(DulHydra::Datastreams::PremisEventDatastream)
    end
  end

  context "before_create callback" do
    after { object.delete }
    context "preservation event with an admin policy" do
      before(:all) { @apo = FactoryGirl.create(:public_read_policy) }
      after(:all) { @apo.delete }
      context "#save" do
        let(:object) { PreservationEvent.new(:admin_policy => @apo) }
        before { object.save }
        it "should retain the assigned policy" do
          object.admin_policy.should == @apo
        end
      end
      context "#create" do
        let(:object) { PreservationEvent.create(:admin_policy => @apo) }
        it "should retain the assigned policy" do
          object.admin_policy.should == @apo
        end
      end
    end
    context "preservation event without an admin policy" do
      context "given that the default admin policy exists" do
        before(:all) { @apo = AdminPolicy.create(:pid => DulHydra::AdminPolicies::PRESERVATION_EVENTS) }
        after(:all) { @apo.delete }
        context "#save" do
          let(:object) { PreservationEvent.new }
          before { object.save }
          it "should be assigned the default policy" do
            object.admin_policy.should == @apo
          end
        end
        context "#create" do
          let(:object) { PreservationEvent.create }
          it "should be assigned the default policy" do
            object.admin_policy.should == @apo
          end
        end        
      end
      context "given that the default policy does not exist" do
        context "#save" do
          let(:object) { PreservationEvent.new }
          before { object.save }
          it "should retain no admin policy" do
            object.admin_policy.should be_nil
          end
        end
        context "#create" do
          let(:object) { PreservationEvent.create }
          it "should retain no admin policy" do
            object.admin_policy.should be_nil
          end
        end                
      end
    end
  end

  context ".fixity_check" do
    subject { PreservationEvent.fixity_check(obj) }
    after { obj.destroy }
    context "success" do
      let(:obj) { FactoryGirl.create(:component_with_content) }
      it_should_behave_like "a fixity check success preservation event"
    end
    context "failure" do
      before { ds_checksum_valid_false(obj.datastreams["content"]) }
      let(:obj) { FactoryGirl.create(:component_with_content) }
      it_should_behave_like "a fixity check failure preservation event"
    end
  end

  context ".fixity_check!" do
    subject { PreservationEvent.fixity_check!(obj) }
    after { obj.destroy }
    context "success" do
      let(:obj) { FactoryGirl.create(:component_with_content) }
      it_should_behave_like "a fixity check success preservation event"
    end
    context "failure" do
      before { ds_checksum_valid_false(obj.datastreams["content"]) }
      let(:obj) { FactoryGirl.create(:component_with_content) }
      it_should_behave_like "a fixity check failure preservation event"
    end
  end

end
