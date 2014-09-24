require 'spec_helper'

describe PermanentIdsController, type: :controller, permanent_ids: true do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }
  describe "when permanent id exists" do
    let!(:obj) { FactoryGirl.create(:collection) }
    it "should redirect to the object" do
      get :show, permanent_id: obj.permanent_id
      expect(response).to be_redirect
    end
  end
end
