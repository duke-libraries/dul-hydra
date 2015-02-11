require 'spec_helper'

describe PermanentIdsController, type: :controller, permanent_ids: true do

  before { skip }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }
  describe "when permanent id exists" do
    let!(:obj) { FactoryGirl.create(:collection) }
    let(:permanent_id) { "ark:/99999/fk4zzz" }
    before do
      obj.permanent_id = permanent_id
      obj.save!
    end
    it "should redirect to the object" do
      get :show, permanent_id: obj.permanent_id
      expect(response).to be_redirect
    end
  end
end
