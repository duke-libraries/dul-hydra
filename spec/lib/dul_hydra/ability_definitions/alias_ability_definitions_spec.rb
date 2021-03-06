require 'spec_helper'
require 'cancan/matchers'

module DulHydra
  RSpec.describe AliasAbilityDefinitions do

    subject { described_class.call(ability) }

    let(:ability) { FactoryGirl.build(:abstract_ability) }

    it "should alias actions to :read" do
      expect(subject.aliased_actions[:read])
        .to include(:attachments, :captions, :components, :duracloud, :event, :events, :files, :intermediate, :items, :stream, :targets)
    end
    it "should alias actions to :grant" do
      expect(subject.aliased_actions[:grant]).to include(:roles)
    end

  end
end
