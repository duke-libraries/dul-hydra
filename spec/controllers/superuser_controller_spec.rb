require 'spec_helper'

describe SuperuserController, type: :controller do

  let(:user) { FactoryGirl.create(:user) }

  before { sign_in :user, user }

  describe "#toggle" do

    let(:previous_page) { "http://library.duke.edu" }

    before do
      request.env["HTTP_REFERER"] = previous_page
      allow(controller.current_user).to receive(:authorized_to_act_as_superuser?) { true }
    end

    it "should redirect to the previous page" do
      get :toggle
      expect(response).to redirect_to(previous_page)
    end

    it "should delete the :create_menu_models session key" do
      expect(session).to receive(:delete).with(:create_menu_models)
      get :toggle
    end

    describe "when the superuser scope is signed in" do
      before { sign_in :superuser, user }
      it "should sign out" do
        expect(controller).to receive(:sign_out).with(:superuser)
        get :toggle
      end
    end

    describe "when the superuser scope is not signed in" do
      it "should sign in" do
        expect(controller).to receive(:sign_in).with(:superuser, user)
        get :toggle
      end
    end

  end

end
