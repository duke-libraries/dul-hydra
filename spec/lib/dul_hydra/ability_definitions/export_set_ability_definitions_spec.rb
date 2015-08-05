require 'spec_helper'
require 'cancan/matchers'

module DulHydra
  RSpec.describe ExportSetAbilityDefinitions do

    subject { described_class.call(ability) }

    describe "user is persisted" do
      let(:ability) { FactoryGirl.build(:abstract_ability) }
      let(:resource) { FactoryGirl.create(:content_export_set_with_pids) }
      it { should be_able_to(:create, ExportSet) }
      it { should_not be_able_to(:read, resource) }

      describe "and is creator of export set" do
        before { allow(ability).to receive(:user) { resource.user } }
        it { should be_able_to(:manage, resource) }
      end
    end

    describe "user is anonymous" do
      let(:ability) { FactoryGirl.build(:abstract_ability, :anonymous) }
      it { should_not be_able_to(:create, ExportSet) }
    end

  end
end
