require 'spec_helper'

describe SuperuserController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in :user, user }
  describe "#toggle" do
    let(:previous_page) { "http://library.duke.edu" }
    before { request.env["HTTP_REFERER"] = previous_page }
    describe "when the superuser scope is signed in" do
      before { sign_in :superuser, user }
      it "should sign out and redirect to the previous page" do
        expect(controller).to receive(:sign_out).with(:superuser)
        get :toggle
        expect(response).to redirect_to(previous_page)
      end
    end
    describe "when the superuser scope is not signed in" do
      before { allow(controller.current_user).to receive(:authorized_to_act_as_superuser?) { true } }
      it "should sign in and redirect to the previous page" do
        expect(controller).to receive(:sign_in).with(:superuser, user)
        get :toggle
        expect(response).to redirect_to(previous_page)
      end
    end
  end
end
