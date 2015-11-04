require "spec_helper"

RSpec.describe "RepositoryController", type: :controller do

  controller(ApplicationController) do
    include DulHydra::Controller::RepositoryBehavior
  end

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "#find_models_with_gated_discovery" do
    let(:model) { Collection }
    let(:collection1) { Collection.create(id: "test-1", dc_title: [ "Collection 1" ]) }
    let(:collection2) { Collection.create(id: "test-2", dc_title: [ "Collection 2" ]) }
    before do
      collection2.roles.grant type: "Viewer", agent: user.agent, scope: "resource"
      collection2.save!
    end
    it "filters out records on which the user lacks :read permission" do
      expect(controller.send(:find_models_with_gated_discovery, model).to_a).to eq([ collection2 ])
    end
  end

end
