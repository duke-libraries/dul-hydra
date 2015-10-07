require 'spec_helper'

describe SuperuserController, type: :controller do

  let(:user) { FactoryGirl.create(:user) }

  before { sign_in :user, user }

  describe "#create" do
    let(:previous_page) { "http://library.duke.edu" }
    before do
      request.env["HTTP_REFERER"] = previous_page
    end
    describe "when the current ability is authorized to act as superuser" do
      before do
        allow(controller).to receive(:authorized_to_act_as_superuser?) { true }
      end
      it "should sign in" do
        expect(controller).to receive(:sign_in).with(:superuser, user)
        get :create
      end
      it "should redirect to the previous page" do
        get :create
        expect(response).to redirect_to(previous_page)
      end
      it "should delete the :create_menu_models session key" do
        expect(session).to receive(:delete).with(:create_menu_models)
        get :create
      end
    end
    describe "when the current ability is not authorized to act as superuser" do
      before do
        allow(controller).to receive(:authorized_to_act_as_superuser?) { false }
      end
      it "should be unauthorized" do
        get :create
        expect(response.response_code).to eq(403)
      end
    end
  end

  describe "#destroy" do
    before { sign_in :superuser, user }
    it "should sign out" do
      expect(controller).to receive(:sign_out).with(:superuser)
      get :destroy
    end
  end

end
