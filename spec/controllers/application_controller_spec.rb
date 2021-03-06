RSpec.describe ApplicationController, type: :controller do

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "#find_models_with_gated_discovery" do
    let(:model) { Collection }
    let(:collection1) { Collection.create(pid: "test:1", title: [ "Collection 1" ], admin_set: "foo") }
    let(:collection2) { Collection.create(pid: "test:2", title: [ "Collection 2" ], admin_set: "foo") }
    before do
      collection2.roles.grant type: "Viewer", agent: user.agent, scope: "resource"
      collection2.save!
    end
    it "should use Blacklight to query solr" do
      expect(controller.send(:find_models_with_gated_discovery, model).to_a).to eq([ collection2 ])
    end
  end

end
