require 'cancan/matchers'

module DulHydra
  RSpec.describe StructureAbilityDefinitions do

    subject { described_class.call(ability) }

    let(:ability) { FactoryGirl.build(:abstract_ability) }

    describe "generate structure" do
      describe "permitted" do
        let(:repo_object) { Item.new }
        before { ability.can :update, repo_object }
        describe "no existing structure" do
          before { allow(repo_object).to receive(:structure) { nil } }
          it { is_expected.to be_able_to(:generate_structure, repo_object) }
        end
        describe "no existing structure" do
          before { allow(repo_object).to receive(:structure) { double(repository_maintained?: true) } }
          it { is_expected.to be_able_to(:generate_structure, repo_object) }
        end
      end

      describe "not permitted" do
        describe "object cannot have structural metadata" do
          let(:repo_object) { Target.new }
          before { ability.can :update, repo_object }
          it { is_expected.to_not be_able_to(:generate_structure, repo_object) }
        end
        describe "object has provided structural metadata" do
          let(:repo_object) { Item.new }
          before do
            ability.can :update, repo_object
            allow(repo_object).to receive(:structure) { double(repository_maintained?: false) }
          end
          it { is_expected.to_not be_able_to(:generate_structure, repo_object) }
        end
      describe "cannot update object" do
        let(:repo_object) { Item.new }
        before do
          ability.cannot :update, repo_object
          allow(repo_object).to receive(:structure) { double(repository_maintained?: true) }
        end
        it { is_expected.to_not be_able_to(:generate_structure, repo_object) }
      end
      end
    end

  end

end
