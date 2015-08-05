require 'spec_helper'
require 'cancan/matchers'

module DulHydra
  RSpec.describe BatchAbilityDefinitions do

    subject { described_class.call(ability) }

    let(:ability) { FactoryGirl.build(:abstract_ability) }

    describe "Batch permissions" do
      let(:resource) { FactoryGirl.create(:batch) }
      describe "when the user is the creator of the batch" do
        before { allow(ability).to receive(:user) { resource.user } }
        it { should be_able_to(:manage, resource) }
      end
      describe "when the user is not the creator of the batch" do
        it { should_not be_able_to(:manage, resource) }
      end
    end

    describe "BatchObject permissions" do
      let(:batch) { FactoryGirl.create(:batch) }
      let(:resource) { DulHydra::Batch::Models::BatchObject.create(batch: batch) }
      before { allow(ability).to receive(:user) { batch.user } }
      describe "when the user can :manage the batch" do
        before { subject.can :manage, batch }
        it { should be_able_to(:manage, resource) }
      end
      describe "when the user cannot :manage the batch" do
        before { subject.cannot :manage, batch }
        it { should_not be_able_to(:manage, resource) }
      end
    end

  end
end
