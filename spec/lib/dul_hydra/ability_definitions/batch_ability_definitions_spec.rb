require 'cancan/matchers'

module DulHydra
  RSpec.describe BatchAbilityDefinitions do

    subject { described_class.call(ability) }

    let(:ability) { FactoryGirl.build(:abstract_ability) }

    describe "Batch permissions" do
      let(:batch) { FactoryGirl.create(:batch) }
      describe "when the user is the creator of the batch" do
        before { allow(ability).to receive(:user) { batch.user } }
        it { is_expected.to be_able_to(:manage, batch) }
      end
      describe "when the user is not the creator of the batch" do
        it { is_expected.to_not be_able_to(:manage, batch) }
        it { is_expected.to be_able_to(:read, batch) }
      end
    end

    describe "BatchObject permissions" do
      let(:batch) { FactoryGirl.create(:batch) }
      let(:resource) { Ddr::Batch::BatchObject.create(batch: batch) }
      describe "when the user is the creator of the batch" do
        before { allow(ability).to receive(:user) { batch.user } }
        it { is_expected.to be_able_to(:manage, resource) }
      end
      describe "when the user is not the creator of the batch" do
        it { is_expected.to_not be_able_to(:manage, resource) }
        it { is_expected.to be_able_to(:read, resource) }
      end
    end

  end

end
